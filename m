Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id A951C6B01AC
	for <linux-mm@kvack.org>; Tue,  6 Jul 2010 03:36:38 -0400 (EDT)
Received: by iwn2 with SMTP id 2so5474941iwn.14
        for <linux-mm@kvack.org>; Tue, 06 Jul 2010 00:36:37 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <AANLkTil6go0otCsBkG_detjptXX_i_mNkkCMawLVIz82@mail.gmail.com>
References: <AANLkTil6go0otCsBkG_detjptXX_i_mNkkCMawLVIz82@mail.gmail.com>
Date: Tue, 6 Jul 2010 16:36:37 +0900
Message-ID: <AANLkTik9TlLYbG4GE6TV1wF7SOXz7v7gQ1BR531HGyNx@mail.gmail.com>
Subject: Re: Need some help in understanding sparsemem.
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: naren.mehra@gmail.com
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 6, 2010 at 2:11 PM,  <naren.mehra@gmail.com> wrote:
> Hi,
>
> I am trying to understand the sparsemem implementation in linux for
> NUMA/multiple node systems.
>
> From the available documentation and the sparsemem patches, I am able
> to make out that sparsemem divides memory into different sections and
> if the whole section contains a hole then its marked as invalid
> section and if some pages in a section form a hole then those pages
> are marked reserved. My issue is that this classification, I am not
> able to map it to the code.
>
> e.g. from arch specific code, we call memory_present() =C2=A0to prepare a
> list of sections in a particular node. but unable to find where
> exactly some sections are marked invalid because they contain a hole.

On ARM's sparsememory,

static void arm_memory_present(struct meminfo *mi)
{
        int i;
        for_each_bank(i, mi) {
                struct membank *bank =3D &mi->bank[i];
                memory_present(0, bank_pfn_start(bank), bank_pfn_end(bank))=
;
        }
}

It just mark _bank_ which has memory with SECTION_MARKED_PRESENT.
Otherwise, Hole.

>
> Can somebody tell me where in the code are we identifying sections as
> invalid and where we are marking pages as reserved.

Do you mean memmap_init_zone?


--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
