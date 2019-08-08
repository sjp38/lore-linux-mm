Return-Path: <SRS0=csuj=WE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 44C76C32751
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 00:27:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CA477214C6
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 00:27:23 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CA477214C6
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fromorbit.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3404C6B0003; Wed,  7 Aug 2019 20:27:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2F17A6B0006; Wed,  7 Aug 2019 20:27:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1E0466B0007; Wed,  7 Aug 2019 20:27:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id DC6DC6B0003
	for <linux-mm@kvack.org>; Wed,  7 Aug 2019 20:27:22 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id t2so54389126plo.10
        for <linux-mm@kvack.org>; Wed, 07 Aug 2019 17:27:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=0rtW9D8FYz64MUjZfBt4I1gYKiLZ7ifa1yirJBqYR20=;
        b=I2FbdjUoHFmR0aTMoJ7Bt3E9iPiQ0iGcyEJ0hklYrxMIeAzED3ix6CNBjT3h856OEQ
         EICH2cge1lKLNKU6xnNOp1T0lMPvlK0mUJ+FX/biVbI7owZN417NMaEq03GuB0k0eCFN
         GFNPpDXp/hc1p86hRqomqczxwITU/MrdDovLc4oIVJN9BOEekv/RMlgDVdSSBIdq/Mgh
         wt3+a/Kv6zotRs1qdoy07vYDZvuNIikylqvxEPKVOnm24OHUgBo+tsF+SAX381MeTFbO
         TaRmhRRl5CK5V5WWwCLTlXIVwxcI9AfzMzztfhYqdAi9UdPVAyTmo/Z8N/RVLOI8n4Qv
         IUPA==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 211.29.132.246 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
X-Gm-Message-State: APjAAAWrdg1We+AkreeGcvYsMaEy5+zC4Z4bHrSMRctmsf0bJdrjPa7W
	CWTepgxztx05wRfBYqncACptD9aeM2caDkVL4V9L/3d9a4P70Yo15iOvmGCxeTz6PgmXk2z+JES
	AmR0gMfaPR+wdtVWKky/Nxb9NXyf8cbkkwDCsfFExCPrYsVVI8iRHQvCJbFm1hv0=
X-Received: by 2002:a63:69c1:: with SMTP id e184mr9627899pgc.198.1565224042469;
        Wed, 07 Aug 2019 17:27:22 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyXzdOfW0a8GIJlC6tCbUI0b8FkHSpKFXARom9I/JByQMHGVznbr1qmYlgsenHLndTtC9RT
X-Received: by 2002:a63:69c1:: with SMTP id e184mr9627840pgc.198.1565224041231;
        Wed, 07 Aug 2019 17:27:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565224041; cv=none;
        d=google.com; s=arc-20160816;
        b=o8wEUu70BfriyASDIinM8behjpEcVd8Fg3/V+nQ5IO6FhtAP6f1XvYomERkojKBvmS
         GBgDCUzvRuVqcReP4KHcWyfZkCyZg6xiOsmeEGlSOtsaLy6ATGncm0IF8E40aRy/Xs19
         tKzs9VzcVXgmscmTiCFI2jR7MKqcyv842mYpo3JorFx2QzhDfUppNmCc6qwffjgGqkbg
         0vZu/E22Ew2abAIWqwAdjiX9hdNMQJcIwPCufWXVoohw4w6kuMV9oJcKaO37ZESoZvzO
         E9RXp51Sed4hwoG6JP0sLm5+UAsZskqbZD/ORL9zmIJSAhIyV77K66NS+60z+0w0PMXD
         N0Ug==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=0rtW9D8FYz64MUjZfBt4I1gYKiLZ7ifa1yirJBqYR20=;
        b=CioBmt7j0vIboG3VfqgtwMhJA6Nf397155h7Uu9lneql733PQhB9wKLnk4RnjWraUI
         wooJoChsHdoDWxF2oFIQRS8WixpB+XTld9iYuZkamdOsuZ9Rp865LwGyDxZd3nbe5zIz
         Tv4Isgh0viaZcVGSz+4Nc9OnKN7kEmj+5K4AqiVm1wzYZhjSPvjcI8Q62NXxbrYc2Bph
         28OBVeWC7sn5sQRP8WJaYBnTyAKyYwTA/XpRU6CGsVKRDRqrhHJX9vEc/fSODzbd1VU5
         MuIU9MngdsDdiGy8+fDc7hofcqEbZvWdSnZOzBsJ8Qo6xiyR+Su5daqTEc+yUMg2ejsp
         W97Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 211.29.132.246 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from mail104.syd.optusnet.com.au (mail104.syd.optusnet.com.au. [211.29.132.246])
        by mx.google.com with ESMTP id a21si50242597pfo.249.2019.08.07.17.27.20
        for <linux-mm@kvack.org>;
        Wed, 07 Aug 2019 17:27:21 -0700 (PDT)
Received-SPF: neutral (google.com: 211.29.132.246 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) client-ip=211.29.132.246;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 211.29.132.246 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from dread.disaster.area (pa49-181-167-148.pa.nsw.optusnet.com.au [49.181.167.148])
	by mail104.syd.optusnet.com.au (Postfix) with ESMTPS id 4A8AD43D3B2;
	Thu,  8 Aug 2019 10:27:18 +1000 (AEST)
Received: from dave by dread.disaster.area with local (Exim 4.92)
	(envelope-from <david@fromorbit.com>)
	id 1hvWFv-0006m6-5A; Thu, 08 Aug 2019 10:26:11 +1000
Date: Thu, 8 Aug 2019 10:26:11 +1000
From: Dave Chinner <david@fromorbit.com>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org,
	linux-xfs@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>
Subject: Re: [PATCH] [Regression, v5.0] mm: boosted kswapd reclaim b0rks
 system cache balance
Message-ID: <20190808002611.GT7777@dread.disaster.area>
References: <20190807091858.2857-1-david@fromorbit.com>
 <20190807093056.GS11812@dhcp22.suse.cz>
 <20190807150316.GL2708@suse.de>
 <20190807205615.GI2739@techsingularity.net>
 <20190807223241.GO7777@dread.disaster.area>
 <20190807234815.GJ2739@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190807234815.GJ2739@techsingularity.net>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Optus-CM-Score: 0
X-Optus-CM-Analysis: v=2.2 cv=D+Q3ErZj c=1 sm=1 tr=0
	a=gu9DDhuZhshYSb5Zs/lkOA==:117 a=gu9DDhuZhshYSb5Zs/lkOA==:17
	a=jpOVt7BSZ2e4Z31A5e1TngXxSK0=:19 a=kj9zAlcOel0A:10 a=FmdZ9Uzk2mMA:10
	a=7-415B0cAAAA:8 a=byWBD9DP03R7pWE3UcEA:9 a=PLYD4zbBjn6pH_M7:21
	a=zYejpdBn9zv0nDCg:21 a=CjuIK1q_8ugA:10 a=biEYGPWJfzWAr4FL6Ov7:22
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 08, 2019 at 12:48:15AM +0100, Mel Gorman wrote:
> On Thu, Aug 08, 2019 at 08:32:41AM +1000, Dave Chinner wrote:
> > On Wed, Aug 07, 2019 at 09:56:15PM +0100, Mel Gorman wrote:
> > > On Wed, Aug 07, 2019 at 04:03:16PM +0100, Mel Gorman wrote:
> > > > <SNIP>
> > > >
> > > > On that basis, it may justify ripping out the may_shrinkslab logic
> > > > everywhere. The downside is that some microbenchmarks will notice.
> > > > Specifically IO benchmarks that fill memory and reread (particularly
> > > > rereading the metadata via any inode operation) may show reduced
> > > > results. Such benchmarks can be strongly affected by whether the inode
> > > > information is still memory resident and watermark boosting reduces
> > > > the changes the data is still resident in memory. Technically still a
> > > > regression but a tunable one.
> > > > 
> > > > Hence the following "it builds" patch that has zero supporting data on
> > > > whether it's a good idea or not.
> > > > 
> > > 
> > > This is a more complete version of the same patch that summaries the
> > > problem and includes data from my own testing
> > ....
> > > A fsmark benchmark configuration was constructed similar to
> > > what Dave reported and is codified by the mmtest configuration
> > > config-io-fsmark-small-file-stream.  It was evaluated on a 1-socket machine
> > > to avoid dealing with NUMA-related issues and the timing of reclaim. The
> > > storage was an SSD Samsung Evo and a fresh XFS filesystem was used for
> > > the test data.
> > 
> > Have you run fstrim on that drive recently? I'm running these tests
> > on a 960 EVO ssd, and when I started looking at shrinkers 3 weeks
> > ago I had all sorts of whacky performance problems and inconsistent
> > results. Turned out there were all sorts of random long IO latencies
> > occurring (in the hundreds of milliseconds) because the drive was
> > constantly running garbage collection to free up space. As a result
> > it was both blocking on GC and thermal throttling under these fsmark
> > workloads.
> > 
> 
> No, I was under the impression that making a new filesystem typically
> trimmed it as well. Maybe that's just some filesystems (e.g. ext4) or
> just completely wrong.

Depends. IIRC, some have turned that off by default because of the
amount of poor implementations that take minutes to trim a whole
device. XFS discards by default, but that doesn't mean it actually
gets done. e.g. it might be on a block device that does not support
or pass down discard requests.

FWIW, I run these in a VM on a sparse filesystem image (500TB) held
in a file on the host XFS filesystem and:

$ cat /sys/block/vdc/queue/discard_max_bytes 
0

Discard requests don't pass down through the virtio block device
(nor do I really want them to). Hence I have to punch the image file
and fstrim on the host side before launching the VM that runs the
tests...

> > then ran
> > fstrim on it to tell the drive all the space is free. Drive temps
> > dropped 30C immediately, and all of the whacky performance anomolies
> > went away. I now fstrim the drive in my vm startup scripts before
> > each test run, and it's giving consistent results again.
> > 
> 
> I'll replicate that if making a new filesystem is not guaranteed to
> trim. It'll muck up historical data but that happens to me every so
> often anyway.

mkfs.xfs should be doing it if you're directly on top of the SSD.
Just wanted to check seeing as I've recently been bitten by this.

> > That looks a lot better. Patch looks reasonable, though I'm
> > interested to know what impact it has on tests you ran in the
> > original commit for the boosting.
> > 
> 
> I'll find out soon enough but I'm leaning on the side that kswapd reclaim
> should be predictable and that even if there are some performance problems
> as a result of it, there will be others that see a gain. It'll be a case
> of "no matter what way you jump, someone shouts" but kswapd having spiky
> unpredictable behaviour is a recipe for "sometimes my machine is crap
> and I've no idea why".

Yeah, and that's precisely the motiviation for getting XFS inode
reclaim to avoid blocking altogether and relying on memory reclaim
to back off when appropriate. I expect there will be other problems
I find with reclaim backoff and blance as a kick the tyres more...

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

