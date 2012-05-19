Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id 998AC6B0081
	for <linux-mm@kvack.org>; Fri, 18 May 2012 20:13:49 -0400 (EDT)
Received: by vbbey12 with SMTP id ey12so5121743vbb.14
        for <linux-mm@kvack.org>; Fri, 18 May 2012 17:13:48 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1337267329.4281.32.camel@twins>
References: <1337133919-4182-1-git-send-email-minchan@kernel.org>
	<1337133919-4182-3-git-send-email-minchan@kernel.org>
	<4FB4B29C.4010908@kernel.org>
	<1337266310.4281.30.camel@twins>
	<1337267329.4281.32.camel@twins>
Date: Sat, 19 May 2012 08:13:48 +0800
Message-ID: <CAGjg+kEu0e=JyMz8F9Wxc36A-TQJ0iSW8LX6d9duZiz172e6AA@mail.gmail.com>
Subject: Re: [PATCH v2 3/3] x86: Support local_flush_tlb_kernel_range
From: Alex Shi <lkml.alex@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Minchan Kim <minchan@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Nitin Gupta <ngupta@vflare.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Tejun Heo <tj@kernel.org>, David Howells <dhowells@redhat.com>, x86@kernel.org, Nick Piggin <npiggin@gmail.com>, Alex Shi <alex.shi@intel.com>

On Thu, May 17, 2012 at 11:08 PM, Peter Zijlstra <peterz@infradead.org> wro=
te:
> On Thu, 2012-05-17 at 16:51 +0200, Peter Zijlstra wrote:
>>
>> Also, does it even work if the range happens to be backed by huge pages?
>> IIRC we try and do the identity map with large pages wherever possible.
>
> OK, the Intel SDM seems to suggest it will indeed invalidate ANY mapping
> to that linear address, which would include 2M and 1G pages.

As for as I know, the 1GB TLB fold into 2MB now, and 2MB page still
maybe fold into 4K page in TLB flush. We are tracking this.

>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org. =A0For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stopthemeter=
.ca/
> Don't email: <a hrefmailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
