Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 3AF785F0019
	for <linux-mm@kvack.org>; Wed,  3 Jun 2009 13:48:22 -0400 (EDT)
Date: Tue, 2 Jun 2009 11:30:12 +0200
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH] Warn if we run out of swap space
Message-ID: <20090602093012.GA17132@elf.ucw.cz>
References: <alpine.DEB.1.10.0905221454460.7673@qirst.com> <4A23FF89.2060603@redhat.com> <20090601123503.2337a79b.akpm@linux-foundation.org> <4A242F94.9010704@redhat.com> <20090602091544.GC15756@elf.ucw.cz> <4A24EF07.6070708@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4A24EF07.6070708@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Avi Kivity <avi@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, cl@linux-foundation.org, linux-mm@kvack.org, dave@linux.vnet.ibm.com
List-ID: <linux-mm.kvack.org>

On Tue 2009-06-02 12:21:11, Avi Kivity wrote:
> Pavel Machek wrote:
>> Ouch and please... don't stop useful printk() warnings just because
>> some 'pie-in-the-sky future binary protocol'. That's what happened in
>> ACPI land with battery critical, and it is also why I don't get
>> battery warnings on some of my machines.
>>   
>
> I don't oppose printk() on significant events (such as this) in addition  
> to a proper programmatic interface.

Good. So lets merge printk now, and someone can create proper
programmatic interface? :-).

(Top can already display swap usage, so I guess interface is really
there but needs to be polled which is ugly... but maybe workable for
this use?)
									Pavel
-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
