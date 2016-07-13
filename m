Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7B93B6B0005
	for <linux-mm@kvack.org>; Wed, 13 Jul 2016 14:24:47 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id f126so40954796wma.3
        for <linux-mm@kvack.org>; Wed, 13 Jul 2016 11:24:47 -0700 (PDT)
Received: from mail.ud19.udmedia.de (ud19.udmedia.de. [194.117.254.59])
        by mx.google.com with ESMTPS id rf19si2353958wjb.127.2016.07.13.11.24.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Jul 2016 11:24:45 -0700 (PDT)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Date: Wed, 13 Jul 2016 20:24:45 +0200
From: Matthias Dahl <ml_linux-kernel@binary-island.eu>
Subject: Re: [dm-devel] Page Allocation Failures/OOM with dm-crypt on software
 RAID10 (Intel Rapid Storage)
In-Reply-To: <2704a8dd-48c5-82b8-890e-72bf5e1ed1e1@redhat.com>
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
 <2704a8dd-48c5-82b8-890e-72bf5e1ed1e1@redhat.com>
Message-ID: <ea16d5fff75b76b4eae2d1b1726c0ea2@mail.ud19.udmedia.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ondrej Kozina <okozina@redhat.com>
Cc: Michal Hocko <mhocko@kernel.org>, linux-raid@vger.kernel.org, linux-mm@kvack.org, dm-devel@redhat.com, linux-kernel@vger.kernel.org, Mike Snitzer <snitzer@redhat.com>

Hello Ondrej...

On 2016-07-13 18:24, Ondrej Kozina wrote:

> One step after another.

Sorry, it was not meant to be rude or anything... more frustration
since I cannot be of more help and I really would like to jump in
head-first and help fixing it... but lack the necessary insight into
the kernel internals. But who knows, I started reading Robert Love's
book... so, in a good decade or so. ;-))

> https://marc.info/?l=linux-mm&m=146825178722612&w=2

Thanks for that link. I have to read those more closely tomorrow, since
there are some nice insights into dm-crypt there. :)

Still, you have to admit, it is also rather frustrating/scary if such
a crucial subsystem can have bugs over several major versions that do
result in complete hangs (and can thus cause corruption) and are quite
easily triggerable. It does not instill too much confidence that said
subsystem is so intensively used/tested after all. That's at least how
I feel about it...

So long,
Matthias

-- 
Dipl.-Inf. (FH) Matthias Dahl | Software Engineer | binary-island.eu
  services: custom software [desktop, mobile, web], server administration

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
