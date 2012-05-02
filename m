Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id 2F8666B004D
	for <linux-mm@kvack.org>; Wed,  2 May 2012 15:15:00 -0400 (EDT)
Received: by ghrr18 with SMTP id r18so1481349ghr.14
        for <linux-mm@kvack.org>; Wed, 02 May 2012 12:14:59 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120502091837.GC16976@quack.suse.cz>
References: <1335778207-6511-1-git-send-email-jack@suse.cz>
 <CAHGf_=qdE3yNw=htuRssfav2pECO1Q0+gWMRTuNROd_3tVrd6Q@mail.gmail.com>
 <CAHGf_=ojhwPUWJR0r+jVgjNd5h_sRrppzJntSpHzxyv+OuBueg@mail.gmail.com>
 <x49ehr4lyw1.fsf@segfault.boston.devel.redhat.com> <CAHGf_=rzcfo3OnwT-YsW2iZLchHs3eBKncobvbhTm7B5PE=L-w@mail.gmail.com>
 <x491un3nc7a.fsf@segfault.boston.devel.redhat.com> <CAPa8GCCgLUt1EDAy7-O-mo0qir6Bf5Pi3Va1EsQ3ZW5UU=+37g@mail.gmail.com>
 <20120502081705.GB16976@quack.suse.cz> <CAPa8GCCnvvaj0Do7sdrdfsvbcAf0zBe3ssXn45gMfDKCcvJWxA@mail.gmail.com>
 <20120502091837.GC16976@quack.suse.cz>
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Date: Wed, 2 May 2012 15:14:33 -0400
Message-ID: <CAHGf_=qfuRZzb91ELEcArNaNHsfO4BBMPO8a-QRBzFNaT2ev_w@mail.gmail.com>
Subject: Re: [PATCH] Describe race of direct read and fork for unaligned buffers
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Nick Piggin <npiggin@gmail.com>, Jeff Moyer <jmoyer@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Michael Kerrisk <mtk.manpages@gmail.com>, LKML <linux-kernel@vger.kernel.org>, linux-man@vger.kernel.org, linux-mm@kvack.org, mgorman@suse.de, Andrea Arcangeli <aarcange@redhat.com>, Woodman <lwoodman@redhat.com>

Hello,

>> I see what you mean.
>>
>> I'm not sure, though. For most apps it's bad practice I think. If you get into
>> realm of sophisticated, performance critical IO/storage managers, it would
>> not surprise me if such concurrent buffer modifications could be allowed.
>> We allow exactly such a thing in our pagecache layer. Although probably
>> those would be using shared mmaps for their buffer cache.
>>
>> I think it is safest to make a default policy of asking for IOs against private
>> cow-able mappings to be quiesced before fork, so there are no surprises
>> or reliance on COW details in the mm. Do you think?
>    Yes, I agree that (and MADV_DONTFORK) is probably the best thing to have
> in documentation. Otherwise it's a bit too hairy...

I neglected this issue for years because Linus asked who need this and
I couldn't
find real world usecase.

Ah, no, not exactly correct. Fujitsu proprietary database had such
usecase. But they
quickly fixed it. Then I couldn't find alternative usecase.

I'm not sure why you say "hairy". Do you mean you have any use case of this?

Thank you.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
