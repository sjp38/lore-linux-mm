Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id 4AD3A6B0031
	for <linux-mm@kvack.org>; Sat, 27 Jul 2013 15:29:56 -0400 (EDT)
Message-ID: <51F41FA0.6060205@parallels.com>
Date: Sat, 27 Jul 2013 23:29:36 +0400
From: Pavel Emelyanov <xemul@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: Save soft-dirty bits on file pages
References: <20130726201807.GJ8661@moon> <CALCETrUJa-Y40vnb6YOPry0dCXb3zCQ0y19i2yHWdzKR75HUzg@mail.gmail.com>
In-Reply-To: <CALCETrUJa-Y40vnb6YOPry0dCXb3zCQ0y19i2yHWdzKR75HUzg@mail.gmail.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Cyrill Gorcunov <gorcunov@gmail.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Matt Mackall <mpm@selenic.com>, Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>, Marcelo Tosatti <mtosatti@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Stephen Rothwell <sfr@canb.auug.org.au>

On 07/27/2013 12:55 AM, Andy Lutomirski wrote:
> On Fri, Jul 26, 2013 at 1:18 PM, Cyrill Gorcunov <gorcunov@gmail.com> wrote:
>> Andy reported that if file page get reclaimed we loose soft-dirty bit
>> if it was there, so save _PAGE_BIT_SOFT_DIRTY bit when page address
>> get encoded into pte entry. Thus when #pf happens on such non-present
>> pte we can restore it back.
>>
> 
> Unless I'm misunderstanding this, it's saving the bit in the
> non-present PTE.  This sounds wrong -- what happens if the entire pmd
> (or whatever the next level is called) gets zapped?  (Also, what
> happens if you unmap a file and map a different file there?)

The whole pte gets zapped on vma unmap, and in this case forgetting
the soft-dirty bit completely is OK.

> --Andy
> .
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
