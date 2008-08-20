Received: by rn-out-0910.google.com with SMTP id j71so179172rne.4
        for <linux-mm@kvack.org>; Wed, 20 Aug 2008 10:58:18 -0700 (PDT)
Message-ID: <2f11576a0808201058u3b0e032atd73cd62730151147@mail.gmail.com>
Date: Thu, 21 Aug 2008 02:58:17 +0900
From: "KOSAKI Motohiro" <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 6/6] Mlock: make mlock error return Posixly Correct
In-Reply-To: <1219249441.6075.14.camel@lts-notebook>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080819210509.27199.6626.sendpatchset@lts-notebook>
	 <20080819210545.27199.5276.sendpatchset@lts-notebook>
	 <20080820163559.12D9.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	 <1219249441.6075.14.camel@lts-notebook>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: akpm@linux-foundation.org, riel@redhat.com, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

>> mlock() need error code if vma permission failure happend.
>> but mmap() (and remap_pages_range(), etc..) should ignore it.
>>
>> So, mlock_vma_pages_range() should ignore __mlock_vma_pages_range()'s error code.
>
> Well, I don't know whether we can trigger a vma permission failure
> during mmap(MAP_LOCKED) or a remap within a VM_LOCKED vma, either of
> which will end up calling mlock_vma_pages_range().  However, [after
> rereading the man page] looks like we DO want to return any ENOMEM w/o
> translating to EAGAIN.

Linus-tree implemetation does it?
Can we make reproduce programs?

So, I think implimentation compatibility is important than man pages
because many person think imcompatibility is bug ;-)


> Guess that means I should do the translation
> from within for mlock() from within mlock_fixup().  remap_pages_range()
> probably wants to explicitly ignore any error from the mlock callout.
>
> Will resend.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
