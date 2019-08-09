Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 11540C433FF
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 14:19:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B87E12171F
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 14:18:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="L0pZUfH1"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B87E12171F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 375C86B0007; Fri,  9 Aug 2019 10:18:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 34CD96B0008; Fri,  9 Aug 2019 10:18:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 23CD66B000A; Fri,  9 Aug 2019 10:18:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f197.google.com (mail-vk1-f197.google.com [209.85.221.197])
	by kanga.kvack.org (Postfix) with ESMTP id 014376B0007
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 10:18:59 -0400 (EDT)
Received: by mail-vk1-f197.google.com with SMTP id r4so41694320vkr.8
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 07:18:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=v2WWG/iOTt94dMfB50rJSprelDOAYAI1KzIRPSZeDWw=;
        b=akrVMTNQ3J3RctO6zyMB57ZYJzMJvO6CF5H8wVnJABU9v6Hs1IGAKtKrjWiZ5UjBf4
         0LVKApmkM5xKirZeUfHKuF+4imbWpQjopb5LTTnyjneG4DMyFqCNd4tH5BQvTDxRqsi3
         lNr2xl/gCGhImWEnT/Nwq6AhSaBP/h7o3uNDjKTrMQs8zzq/PsOHLQSZRCvHGSBtU35C
         x5kKNcaPamN5wWNfDc5ZlivJ3XVSxzacDRUMCZU+5vervmx6SE9ynvUK7RDt1ORYX9Ok
         s4hzg6e756z/8GjnJ8BqEnAgtly29h5CLi2rpN8vwGgJNgn+l9UHjcoH26eSGatbECt9
         1tjw==
X-Gm-Message-State: APjAAAVYEG8+Wz5wkjhHilftszlT1OwzEMcmEpJTb6O6rJJvKHAhtrqg
	yYjpOO1BYQFbJgAEr0pZuZnI2B0jk3SXG1URn8VsQg8mrsYcDoVNctmrerm/32sjEAxyDZqJiKn
	/u8KWLEDrixv6qlqWoDt1EHUf1syvYN/cm9dsj+FN2Flvp4Z3BgcNdfBs8Kq/0ddKqA==
X-Received: by 2002:ab0:30e1:: with SMTP id d1mr12661138uam.112.1565360338580;
        Fri, 09 Aug 2019 07:18:58 -0700 (PDT)
X-Received: by 2002:ab0:30e1:: with SMTP id d1mr12661077uam.112.1565360337388;
        Fri, 09 Aug 2019 07:18:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565360337; cv=none;
        d=google.com; s=arc-20160816;
        b=SHMC8x7oBwEKvBymm9tn/9mSppbANUuEOKHBF1NCk7DNHzd7MhdRZYxNaqCRl+91Q4
         9lHpIQYIT7t57fqSETipO94mb5NbzHiI1AiV/lEbZsR4BAR4iOit26+s0Gfsvwtcs0Z1
         SKaVwUTFtI84s0aa8z8ZmKR7U/NiNvkHbeYZosQNIlUtzmJkoLk6Hu6hXGF68pEl69sp
         CyIeTim7IMVnL2vtjj7MTR+lHAVOxWaco2wLQnNFHtDWLszf6iTPMtuWrkD7+sTELfc6
         RB/9goKmDVroyXorFSgAP4alqiKAbK8rFlwg1/snz+ZscEhSJaJHWaVJuTkqIn+DIOpr
         iSXw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=v2WWG/iOTt94dMfB50rJSprelDOAYAI1KzIRPSZeDWw=;
        b=HipQzH/KiUXAyaMCpA6qbrIrEp9sq4Kgud7zFr0gceC6vJKoByFVYBdO/m2bAMvJur
         TtxH1c41ZDoGbHTHNnzZ6WtCgVFdr1yzQQLcKs1/vjrdZlwYGOuOHVIhT3BPPG8i99Jf
         MfzgM2wa6TpSl8CEhL46qtojEKykX5yXJklQwVUnwKeA4z1c4yh+qH/vhz7eadCSSFOE
         lzMB4gkzaZ3XRdLvR07c+JypgP2CrtAeConPldDT8gP5jbuD2nMzjelojOLM8sOQlaNk
         bNMSBQIKx0hs23xiZHnNTCRI2X//WzzSyz0c0GHPH95b9Z8UQ2utt6BqOy2hGIqsHXVH
         4crg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=L0pZUfH1;
       spf=pass (google.com: domain of pintu.ping@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=pintu.ping@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id i26sor1408933uat.15.2019.08.09.07.18.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 09 Aug 2019 07:18:57 -0700 (PDT)
Received-SPF: pass (google.com: domain of pintu.ping@gmail.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=L0pZUfH1;
       spf=pass (google.com: domain of pintu.ping@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=pintu.ping@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=v2WWG/iOTt94dMfB50rJSprelDOAYAI1KzIRPSZeDWw=;
        b=L0pZUfH1Uew/sDujE8pVsgpmSmCUSh/9v+Pm7AP7dGoWu3bbFxKnx/3EcFxtHRPa3t
         UfWE4qPsSieR1Oe2PcbiK5Y2dvSwWL2G7KsbVvBkddBqYDBIGYApL7PtXBXwpRc7/a69
         iqhUPNJ96VGAcIh0004onXloMthwIiwxNhghfaBPVb7Qj2OcPaSaOWn59wyvdV6yIHoE
         FISEPK2OWvJZH+HIlCd443YXuwMuV3Sbj8iQkVW9ezjUn4rshGiDPuiSblhbEGzLQoSd
         Owk2Ct8izWotiIN0D8dVtpAjDFF8znMsSw8tWksjOdwKeSnOAYW7A3SHCaXm8QzvqymQ
         QLvQ==
X-Google-Smtp-Source: APXvYqwPqrzwFtGX8NI73Jdcu/90zyRirukekqbQj1hpKKql3cvsF4mO9y3zDSB4f5aWhKn0nUHkZu30WEPW9VtTdLo=
X-Received: by 2002:ab0:30ae:: with SMTP id b14mr2034666uam.22.1565360336786;
 Fri, 09 Aug 2019 07:18:56 -0700 (PDT)
MIME-Version: 1.0
References: <20190807075927.GO11812@dhcp22.suse.cz> <20190807205138.GA24222@cmpxchg.org>
 <20190808114826.GC18351@dhcp22.suse.cz> <806F5696-A8D6-481D-A82F-49DEC1F2B035@redhazel.co.uk>
 <20190808163228.GE18351@dhcp22.suse.cz> <5FBB0A26-0CFE-4B88-A4F2-6A42E3377EDB@redhazel.co.uk>
 <20190808185925.GH18351@dhcp22.suse.cz> <08e5d007-a41a-e322-5631-b89978b9cc20@redhazel.co.uk>
 <20190809085748.GN18351@dhcp22.suse.cz> <cdb392ee-e192-c136-41cb-48d9e4e4bf47@redhazel.co.uk>
 <20190809105016.GP18351@dhcp22.suse.cz>
In-Reply-To: <20190809105016.GP18351@dhcp22.suse.cz>
From: Pintu Agarwal <pintu.ping@gmail.com>
Date: Fri, 9 Aug 2019 19:48:45 +0530
Message-ID: <CAOuPNLiQ7je5DKwTBqxRHoeu_rchFGrBcb1Cdy2Rczt_VsMaNg@mail.gmail.com>
Subject: Re: Let's talk about the elephant in the room - the Linux kernel's
 inability to gracefully handle low memory pressure
To: Michal Hocko <mhocko@kernel.org>
Cc: ndrw <ndrw.xf@redhazel.co.uk>, Johannes Weiner <hannes@cmpxchg.org>, 
	Suren Baghdasaryan <surenb@google.com>, Vlastimil Babka <vbabka@suse.cz>, "Artem S. Tashkinov" <aros@gmx.com>, 
	Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, 
	linux-mm <linux-mm@kvack.org>, Pintu Kumar <pintu.ping@gmail.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

[...]

Hi,

This is an interesting topic for me so I would like to join the conversation.
I will be glad if I can be of any help here either in testing PSI, or
verifying some scenarios and observation.

I have some experience working with low memory embedded devices, like
RAM as low as 128MB, 256MB, less than 1GB mostly, with/without
Display, DRM/Graphics support.
Along with ZRAM as swap space configured as 25% of RAM size.
The eMMC storage space is also as low as 4GB or 8GB max.

So, I have experienced this sluggishness, hang, OOM kill issues quite
a number of times.
So, I would like to share my experience and observation here.

Recently, I have been exploring the PSI feature on my ARM
Qemu/Beagle-Bone environment, so I can share some feedback for this as
well.

The system sluggish behavior can result from 4 types (specially on
smart phone devices):
* memory allocation pressure
* I/O pressure
* Scheduling pressure
* Network pressure

I think the topic of concern here is: memory pressure.
So, I would like to share some thoughts about this.

* In my opinion, memory pressure should be internal to the system and
not visible to the end users.
* The pressure metrics can very from system to system, so its
difficult to apply single policy.
* I guess this is the time to apply "Machine Learning" and "Artificial
Intelligence" into the system :)

* The memory pressure starts with how many times and how quickly
system is entering the slow-path.
  Thus slow-path monitoring may give some clue about pressure building
in the system.
  Thus I use to use slow-path-counter.
  Too much of slow-path in the beginning itself indicates that this
system needs to be re-designed.

* The system should be avoided to entering slow-path again and again
thus avoiding pressure.
  If this happens then its time to reclaim memory in large chunk,
rather than in smaller chunk.
  May be its time to think about shrink_all_memory() knob in kernel.
  It can be run as bottom-half processing, may be from cgroups.

* Some experiment were done in the past. Interested people can check this paper:
  http://events17.linuxfoundation.org/sites/events/files/slides/%5BELC-2015%5D-System-wide-Memory-Defragmenter.pdf

* The system is already behaving sluggish even before it enters oom-kill stage.
  So, most of the time oom stage is skipped, not occurred, or its just
looping around.
  Thus, some kind of oom-monitoring may help to gather some suspect.
  Thats the reason I proposed to use something called
oom-stall-counter. That means system entering oom, but not possibly
oom-kill.
  If this counter is updated means we assume that system started
behaving sluggish.

* A oom-kill-counter can also help in determining how much of killing
happening in kernel space.
  Example: If PSI pressure is building up and this counter is not updating...
  But in any case system-daemon should be avoided from killing.

* Some killing policy should be left to user space. So a standard
system-daemon (or kthread) should be designed along the line.
  It should be configured dynamically based on the system and oom-score.
  As my previous experience, in Tizen, we have used something called:
resourced daemon.
  https://git.tizen.org/cgit/platform/core/system/resourced/tree/src/memory?h=tizen

* Instead of static policy there should be something called "Dynamic
Low Memory Manager" (DLLM) policy.
  That is at every stage (slow-path, swapping, compaction-fail,
reclaim-fail, oom) some action can be taken.
  Earlier this event was triggered using vmpressure, but now it can
replace with PSI.

* Another major culprit with sluggish in the long run is, the
system-daemon occupying all of swap space and never releasing it.
  So, even if the kill applications due to oom, it may not help much.
Since daemons will never be killed.
  So, I proposed something called "Dynamic Swappiness", where
swappiness of daemons came be lowered dynamically, while normal
application have higher values.
  In the past I have done several experiments on this, soon I will be
publishing a paper on it.

* May be it is helpful to understand better, if we start from a very
minimal scale (just 64MB to 512MB RAM) with busy-box.
  If we can tune this perfectly, than large scale will automatically
have no issues.

With respect to PSI, here are my observations:
* PSI memory threshold (10, 60, 300) are too high for an embedded system.
  I think these settings should be dynamic, or user configurable, or
there should be on more entry for 1s or lesser.
* PSI memory values are updated after the oom-kill in kernel had
already happened, that means sluggish already occurred.
  So, I have to utilize the "total" field and monitor the difference manually.
  Like the difference between previous-total and next-total is more
than 100ms and rising, then we suspect OOM.
* Currently, PSI values are system-wide. That is, after sluggish
occurred, it is difficult to predict, which task causes sluggish.
  So, I was thinking to add new entry to capture task details as well.


These are some of my opinion. It may or may not be applicable directly.
Further brain-storming or discussions might be required.



Regards,
Pintu

