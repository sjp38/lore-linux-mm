Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f198.google.com (mail-yw0-f198.google.com [209.85.161.198])
	by kanga.kvack.org (Postfix) with ESMTP id B35CE6B0253
	for <linux-mm@kvack.org>; Wed, 13 Jul 2016 12:24:56 -0400 (EDT)
Received: by mail-yw0-f198.google.com with SMTP id m62so101545935ywd.1
        for <linux-mm@kvack.org>; Wed, 13 Jul 2016 09:24:56 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id h23si2726975qtb.114.2016.07.13.09.24.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Jul 2016 09:24:55 -0700 (PDT)
Subject: Re: [dm-devel] Page Allocation Failures/OOM with dm-crypt on software
 RAID10 (Intel Rapid Storage)
References: <02580b0a303da26b669b4a9892624b13@mail.ud19.udmedia.de>
 <20160712095013.GA14591@dhcp22.suse.cz>
 <d9dbe0328e938eb7544fdb2aa8b5a9c7@mail.ud19.udmedia.de>
 <20160712114920.GF14586@dhcp22.suse.cz>
 <e6c2087730e530e77c2b12d50495bdc9@mail.ud19.udmedia.de>
 <20160712140715.GL14586@dhcp22.suse.cz>
 <459d501038de4d25db6d140ac5ea5f8d@mail.ud19.udmedia.de>
 <20160713112126.GH28723@dhcp22.suse.cz>
 <20160713121828.GI28723@dhcp22.suse.cz>
 <74b9325c37948cf2b460bd759cff23dd@mail.ud19.udmedia.de>
 <20160713134717.GL28723@dhcp22.suse.cz>
 <a6e48e37cce530f286e6669fdfc0b3f8@mail.ud19.udmedia.de>
From: Ondrej Kozina <okozina@redhat.com>
Message-ID: <2704a8dd-48c5-82b8-890e-72bf5e1ed1e1@redhat.com>
Date: Wed, 13 Jul 2016 18:24:51 +0200
MIME-Version: 1.0
In-Reply-To: <a6e48e37cce530f286e6669fdfc0b3f8@mail.ud19.udmedia.de>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthias Dahl <ml_linux-kernel@binary-island.eu>, Michal Hocko <mhocko@kernel.org>
Cc: linux-raid@vger.kernel.org, linux-mm@kvack.org, dm-devel@redhat.com, linux-kernel@vger.kernel.org, Mike Snitzer <snitzer@redhat.com>

On 07/13/2016 05:32 PM, Matthias Dahl wrote:
>
> No matter what, I have no clue how to further diagnose this issue. And
> given that I already had unsolvable issues with dm-crypt a couple of
> months ago with my old machine where the system simply hang itself or
> went OOM when the swap was encrypted and just a few kilobytes needed to
> be swapped out, I am not so sure anymore I can trust dm-crypt with a
> full disk encryption to the point where I feel "safe"... as-in, nothing
> bad will happen or the system won't suddenly hang itself due to it. Or
> if a bug is introduced, that it will actually be possible to diagnose it
> and help fix it or that it will even be eventually fixed. Which is
> really
> a pity, since I would really have liked to help solve this. With the
> swap issue, I did git bisects, tests, narrowed it down to kernel
> versions
> when said bug was introduced... but in the end, the bug is still present
> as far as I know. :(
>

One step after another. Mathias, your original report was not forgotten, 
it's just not so easy to find the real culprit and fix it without 
causing yet another regression. See the 
https://marc.info/?l=linux-mm&m=146825178722612&w=2 thread...

Not to mention that on current 4.7-rc7 kernels it behaves yet slightly 
differently (yet far from ideally).

Regards O.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
