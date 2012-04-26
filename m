Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id E62926B0044
	for <linux-mm@kvack.org>; Wed, 25 Apr 2012 20:50:59 -0400 (EDT)
Received: by yhr47 with SMTP id 47so848869yhr.14
        for <linux-mm@kvack.org>; Wed, 25 Apr 2012 17:50:59 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120425222819.GF8989@google.com>
References: <CAHnt0GXW-pyOUuBLB1n6qBP4WNGpET9er_HbJ29s5j5DE1xAdA@mail.gmail.com>
	<20120425222819.GF8989@google.com>
Date: Thu, 26 Apr 2012 08:50:58 +0800
Message-ID: <CAHnt0GWABX8qOVTinmSETUHxq1Y3NhqPOKxnUgcDtyf8wjtg_g@mail.gmail.com>
Subject: Re: [BUG]memblock: fix overflow of array index
From: Peter Teoh <htmldeveloper@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: linux-kernel@vger.kernel.org, "H. Peter Anvin" <hpa@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, linux-mm@kvack.org

Thanks for the reply.   Just an educational question:  is it possible
to set one-byte per memblock?    And what is the minimum memblock
size?

Even if 2G memblock is a huge number, it still seemed like a bug to me
that there is no check on the maximum number (which is 2G) of this
variable (assuming signed int).   Software can always purposely push
that number up and the system can panic?

On Thu, Apr 26, 2012 at 6:28 AM, Tejun Heo <tj@kernel.org> wrote:
> On Wed, Apr 25, 2012 at 04:30:19PM +0800, Peter Teoh wrote:
>> Fixing the mismatch in signed and unsigned type assignment, which
>> potentially can lead to integer overflow bug.
>>
>> Thanks.
>>
>> Reviewed-by: Minchan Kim <minchan@kernel.org>
>> Signed-off-by: Peter Teoh <htmldeveloper@gmail.com>
>
> All indexes in memblock are integers. =A0Changing that particular one to
> unsigned int doesn't fix anything. =A0I think it just makes things more
> confusing. =A0If there ever are cases w/ more then 2G memblocks, we're
> going for 64bit not unsigned.
>
> Thanks.
>
> --
> tejun



--=20
Regards,
Peter Teoh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
