Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id 2E5076B0036
	for <linux-mm@kvack.org>; Tue, 16 Apr 2013 12:27:22 -0400 (EDT)
Received: by mail-qe0-f48.google.com with SMTP id 2so368259qea.35
        for <linux-mm@kvack.org>; Tue, 16 Apr 2013 09:27:21 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <516CF7BB.3050301@gmail.com>
References: <5114DF05.7070702@mellanox.com>
	<CAH3drwbjQa2Xms30b8J_oEUw7Eikcno-7Xqf=7=da3LHWXvkKA@mail.gmail.com>
	<516CF7BB.3050301@gmail.com>
Date: Tue, 16 Apr 2013 12:27:21 -0400
Message-ID: <CAH3drwbx1aiQEA19+zq6t=GPPNZQEkD27sCjL-Ma2aYns7pMXw@mail.gmail.com>
Subject: Re: [LSF/MM TOPIC] Hardware initiated paging of user process pages,
 hardware access to the CPU page tables of user processes
From: Jerome Glisse <j.glisse@gmail.com>
Content-Type: multipart/alternative; boundary=047d7b5d617cfa98ab04da7cd72e
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Simon Jeons <simon.jeons@gmail.com>
Cc: Shachar Raindel <raindel@mellanox.com>, lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org, Andrea Arcangeli <aarcange@redhat.com>, Roland Dreier <roland@purestorage.com>, Haggai Eran <haggaie@mellanox.com>, Or Gerlitz <ogerlitz@mellanox.com>, Sagi Grimberg <sagig@mellanox.com>, Liran Liss <liranl@mellanox.com>

--047d7b5d617cfa98ab04da7cd72e
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On Tue, Apr 16, 2013 at 3:03 AM, Simon Jeons <simon.jeons@gmail.com> wrote:

> Hi Jerome,
>
> On 02/08/2013 11:21 PM, Jerome Glisse wrote:
>
>> On Fri, Feb 8, 2013 at 6:18 AM, Shachar Raindel <raindel@mellanox.com>
>> wrote:
>>
>>> Hi,
>>>
>>> We would like to present a reference implementation for safely sharing
>>> memory pages from user space with the hardware, without pinning.
>>>
>>> We will be happy to hear the community feedback on our prototype
>>> implementation, and suggestions for future improvements.
>>>
>>> We would also like to discuss adding features to the core MM subsystem =
to
>>> assist hardware access to user memory without pinning.
>>>
>>> Following is a longer motivation and explanation on the technology
>>> presented:
>>>
>>> Many application developers would like to be able to be able to
>>> communicate
>>> directly with the hardware from the userspace.
>>>
>>> Use cases for that includes high performance networking API such as
>>> InfiniBand, RoCE and iWarp and interfacing with GPUs.
>>>
>>> Currently, if the user space application wants to share system memory
>>> with
>>> the hardware device, the kernel component must pin the memory pages in
>>> RAM,
>>> using get_user_pages.
>>>
>>> This is a hurdle, as it usually makes large portions the application
>>> memory
>>> unmovable. This pinning also makes the user space development model ver=
y
>>> complicated =96 one needs to register memory before using it for
>>> communication
>>> with the hardware.
>>>
>>> We use the mmu-notifiers [1] mechanism to inform the hardware when the
>>> mapping of a page is changed. If the hardware tries to access a page
>>> which
>>> is not yet mapped for the hardware, it requests a resolution for the pa=
ge
>>> address from the kernel.
>>>
>>> This mechanism allows the hardware to access the entire address space o=
f
>>> the
>>> user application, without pinning even a single page.
>>>
>>> We would like to use the LSF/MM forum opportunity to discuss open issue=
s
>>> we
>>> have for further development, such as:
>>>
>>> -Allowing the hardware to perform page table walk, similar to
>>> get_user_pages_fast to resolve user pages that are already in RAM.
>>>
>>
> get_user_pages_fast just get page reference count instead of populate the
> pte to page table, correct? Then how can GPU driver use iommu to access t=
he
> page?
>

As i said this is for pre-filling already present entry, ie pte that are
present with a valid page (no special bit set). This is an optimization so
that the GPU can pre-fill its tlb without having to take any mmap_sem. Hope
is that in most common case this will be enough, but in some case you will
have to go through the lengthy non fast gup.

Cheers,
Jerome

--047d7b5d617cfa98ab04da7cd72e
Content-Type: text/html; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

<div class=3D"gmail_quote">On Tue, Apr 16, 2013 at 3:03 AM, Simon Jeons <sp=
an dir=3D"ltr">&lt;<a href=3D"mailto:simon.jeons@gmail.com" target=3D"_blan=
k">simon.jeons@gmail.com</a>&gt;</span> wrote:<br><blockquote class=3D"gmai=
l_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left=
:1ex">
Hi Jerome,<div><div class=3D"h5"><br>
On 02/08/2013 11:21 PM, Jerome Glisse wrote:<br>
<blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1p=
x #ccc solid;padding-left:1ex">
On Fri, Feb 8, 2013 at 6:18 AM, Shachar Raindel &lt;<a href=3D"mailto:raind=
el@mellanox.com" target=3D"_blank">raindel@mellanox.com</a>&gt; wrote:<br>
<blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1p=
x #ccc solid;padding-left:1ex">
Hi,<br>
<br>
We would like to present a reference implementation for safely sharing<br>
memory pages from user space with the hardware, without pinning.<br>
<br>
We will be happy to hear the community feedback on our prototype<br>
implementation, and suggestions for future improvements.<br>
<br>
We would also like to discuss adding features to the core MM subsystem to<b=
r>
assist hardware access to user memory without pinning.<br>
<br>
Following is a longer motivation and explanation on the technology<br>
presented:<br>
<br>
Many application developers would like to be able to be able to communicate=
<br>
directly with the hardware from the userspace.<br>
<br>
Use cases for that includes high performance networking API such as<br>
InfiniBand, RoCE and iWarp and interfacing with GPUs.<br>
<br>
Currently, if the user space application wants to share system memory with<=
br>
the hardware device, the kernel component must pin the memory pages in RAM,=
<br>
using get_user_pages.<br>
<br>
This is a hurdle, as it usually makes large portions the application memory=
<br>
unmovable. This pinning also makes the user space development model very<br=
>
complicated =96 one needs to register memory before using it for communicat=
ion<br>
with the hardware.<br>
<br>
We use the mmu-notifiers [1] mechanism to inform the hardware when the<br>
mapping of a page is changed. If the hardware tries to access a page which<=
br>
is not yet mapped for the hardware, it requests a resolution for the page<b=
r>
address from the kernel.<br>
<br>
This mechanism allows the hardware to access the entire address space of th=
e<br>
user application, without pinning even a single page.<br>
<br>
We would like to use the LSF/MM forum opportunity to discuss open issues we=
<br>
have for further development, such as:<br>
<br>
-Allowing the hardware to perform page table walk, similar to<br>
get_user_pages_fast to resolve user pages that are already in RAM.<br>
</blockquote></blockquote>
<br></div></div>
get_user_pages_fast just get page reference count instead of populate the p=
te to page table, correct? Then how can GPU driver use iommu to access the =
page?<br></blockquote><div><br>As i said this is for pre-filling already pr=
esent entry, ie pte that are present with a valid page (no special bit set)=
. This is an optimization so that the GPU can pre-fill its tlb without havi=
ng to take any mmap_sem. Hope is that in most common case this will be enou=
gh, but in some case you will have to go through the lengthy non fast gup.<=
br>
<br></div></div>Cheers,<br>Jerome<br>

--047d7b5d617cfa98ab04da7cd72e--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
