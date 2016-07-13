Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7CC8D6B025F
	for <linux-mm@kvack.org>; Wed, 13 Jul 2016 09:18:13 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id p41so33032274lfi.0
        for <linux-mm@kvack.org>; Wed, 13 Jul 2016 06:18:13 -0700 (PDT)
Received: from mail.ud19.udmedia.de (ud19.udmedia.de. [194.117.254.59])
        by mx.google.com with ESMTPS id ff4si923744wjb.191.2016.07.13.06.18.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Jul 2016 06:18:12 -0700 (PDT)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Date: Wed, 13 Jul 2016 15:18:11 +0200
From: Matthias Dahl <ml_linux-kernel@binary-island.eu>
Subject: Re: Page Allocation Failures/OOM with dm-crypt on software RAID10
 (Intel Rapid Storage)
In-Reply-To: <20160713121828.GI28723@dhcp22.suse.cz>
References: <02580b0a303da26b669b4a9892624b13@mail.ud19.udmedia.de>
 <20160712095013.GA14591@dhcp22.suse.cz>
 <d9dbe0328e938eb7544fdb2aa8b5a9c7@mail.ud19.udmedia.de>
 <20160712114920.GF14586@dhcp22.suse.cz>
 <e6c2087730e530e77c2b12d50495bdc9@mail.ud19.udmedia.de>
 <20160712140715.GL14586@dhcp22.suse.cz>
 <459d501038de4d25db6d140ac5ea5f8d@mail.ud19.udmedia.de>
 <20160713112126.GH28723@dhcp22.suse.cz>
 <20160713121828.GI28723@dhcp22.suse.cz>
Message-ID: <74b9325c37948cf2b460bd759cff23dd@mail.ud19.udmedia.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-raid@vger.kernel.org, linux-mm@kvack.org, dm-devel@redhat.com, linux-kernel@vger.kernel.org, Mike Snitzer <snitzer@redhat.com>

Hello Michal,

many thanks for all your time and help on this issue. It is very much
appreciated and I hope we can track this down somehow.

On 2016-07-13 14:18, Michal Hocko wrote:

> So it seems we are accumulating bios and 256B objects. Buffer heads as
> well but so much. Having over 4G worth of bios sounds really 
> suspicious.
> Note that they pin pages to be written so this might be consuming the
> rest of the unaccounted memory! So the main question is why those bios
> do not get dispatched or finished.

Ok. It is the Block IOs that do not get completed. I do get it right
that those bio-3 are already the encrypted data that should be written
out but do not for some reason? I tried to figure this out myself but
couldn't find anything -- what does the number "-3" state? It is the
position in some chain or has it a different meaning?

Do you think a trace like you mentioned would help shed some more light
on this? Or would you recommend something else?

I have also cc' Mike Snitzer who commented on this issue before, maybe
he can see some pattern here as well. Pity that Neil Brown is no longer
available as I think this is also somehow related to it being a Intel
Rapid Storage RAID10... since it is the only way I can reproduce it. :(

Thanks,
Matthias

-- 
Dipl.-Inf. (FH) Matthias Dahl | Software Engineer | binary-island.eu
  services: custom software [desktop, mobile, web], server administration

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
