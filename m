Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 86A736B002C
	for <linux-mm@kvack.org>; Thu, 13 Oct 2011 00:48:33 -0400 (EDT)
Received: by mail-yw0-f52.google.com with SMTP id 31so1023112ywp.39
        for <linux-mm@kvack.org>; Wed, 12 Oct 2011 21:48:30 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4E9614FA.20108@xenotime.net>
References: <1318325033-32688-1-git-send-email-sumit.semwal@ti.com>
 <1318325033-32688-3-git-send-email-sumit.semwal@ti.com> <4E9614FA.20108@xenotime.net>
From: "Semwal, Sumit" <sumit.semwal@ti.com>
Date: Thu, 13 Oct 2011 10:18:10 +0530
Message-ID: <CAB2ybb8RTdUt8w2T74KH=hJoe9_tV41Ua_Z4x4kWa64OpXOe+A@mail.gmail.com>
Subject: Re: [RFC 2/2] dma-buf: Documentation for buffer sharing framework
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Randy Dunlap <rdunlap@xenotime.net>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, dri-devel@lists.freedesktop.org, linux-media@vger.kernel.org, linux@arm.linux.org.uk, arnd@arndb.de, jesse.barker@linaro.org, m.szyprowski@samsung.com, rob@ti.com, daniel@ffwll.ch, t.stanislaws@samsung.com, Sumit Semwal <sumit.semwal@linaro.org>

Hi Randy,
On Thu, Oct 13, 2011 at 4:00 AM, Randy Dunlap <rdunlap@xenotime.net> wrote:
> On 10/11/2011 02:23 AM, Sumit Semwal wrote:
>> Add documentation for dma buffer sharing framework, explaining the
>> various operations, members and API of the dma buffer sharing
>> framework.
>>
>> Signed-off-by: Sumit Semwal <sumit.semwal@linaro.org>
>> Signed-off-by: Sumit Semwal <sumit.semwal@ti.com>
>> ---
>> =A0Documentation/dma-buf-sharing.txt | =A0210 ++++++++++++++++++++++++++=
+++++++++++
<snip>
>> + =A0 =A0if the new buffer-user has stricter 'backing-storage constraint=
s', and the
>> + =A0 =A0exporter can handle these constraints, the exporter can just st=
all on the
>> + =A0 =A0get_scatterlist till all outstanding access is completed (as si=
gnalled by
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 until
>
Thanks for your review; I will update all these in the next version.
>> + =A0 =A0put_scatterlist).
>> + =A0 =A0Once all ongoing access is completed, the exporter could potent=
ially move
>> + =A0 =A0the buffer to the stricter backing-storage, and then allow furt=
her
>> + =A0 =A0{get,put}_scatterlist operations from any buffer-user from the =
migrated
>> + =A0 =A0backing-storage.
>> +
>> + =A0 If the exporter cannot fulfill the backing-storage constraints of =
the new
>> + =A0 buffer-user device as requested, dma_buf_attach() would return an =
error to
>> + =A0 denote non-compatibility of the new buffer-sharing request with th=
e current
>> + =A0 buffer.
>> +
>> + =A0 If the exporter chooses not to allow an attach() operation once a
>> + =A0 get_scatterlist has been called, it simply returns an error.
>> +
>> +- mmap file operation
>> + =A0 An mmap() file operation is provided for the fd associated with th=
e buffer.
>> + =A0 If the exporter defines an mmap operation, the mmap() fop calls th=
is to allow
>> + =A0 mmap for devices that might need it; if not, it returns an error.
>> +
>> +References:
>> +[1] struct dma_buf_ops in include/linux/dma-buf.h
>> +[2] All interfaces mentioned above defined in include/linux/dma-buf.h
>
>
> --
> ~Randy
> *** Remember to use Documentation/SubmitChecklist when testing your code =
***
>
Best regards,
~Sumit.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
