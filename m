Return-Path: <SRS0=ywda=QG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_NEOMUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 01038C282D7
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 21:52:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8DA0120989
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 21:52:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8DA0120989
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 59C588E0003; Wed, 30 Jan 2019 16:52:07 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 54C868E0001; Wed, 30 Jan 2019 16:52:07 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 43D648E0003; Wed, 30 Jan 2019 16:52:07 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id F21928E0001
	for <linux-mm@kvack.org>; Wed, 30 Jan 2019 16:52:06 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id t2so351340edb.22
        for <linux-mm@kvack.org>; Wed, 30 Jan 2019 13:52:06 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=zxSGNaFIVoRstPCm1KhTV/yJY1B7kx/Nhz8PiuhkOZs=;
        b=KmcFFBVk7OfVvxKDLU8Ng67FeoTN4RSEVNVv9ICveSnibwlwjGifycNd5V6B4/RCl5
         RANpe8+6saZbIrTwKHTyHy3Hv3j0JAwLtG+YrSVujs3oRE0F8kLeQ3Yy7rYiFImPEucx
         tjkRbuVrNqehpIJWUwO8xQ6X5b8dwnwkLqXM4VSaBGnMdluQoAB8wNNBsU1ikcWBFWBj
         MIaqAqh7aaFsmgNCi3Bt8VhM5nmZWJ/dRF13aJAncIGAiMio6UJBYQK/T6KLi/Qh9Q0M
         y8Vb3GRPCKlEJZn6oHOegSFyJ2Xup+8L1GZT1gr76jyvsTkH1pEsWEsapK+SuLumXi2m
         5iaQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: AJcUuke8JHeJrfQqlczv1hTm02GcuWKqMALka7yfHWHnGZgvOmcvWaz+
	JaLywnZ5i3rd01NXpUw1OVXwK0xHh6xQUxhpnNBsl9uLL9wAdD58R3MG8KfYSlxsthU2+R/v/wD
	DU7EPtZtyUNoIipqFeCHvH7SC106VEQELK6V3E3Z8UF3wAb24vfXgXrjUMg9BLavBAw==
X-Received: by 2002:a17:906:f146:: with SMTP id gw6mr28322341ejb.176.1548885126566;
        Wed, 30 Jan 2019 13:52:06 -0800 (PST)
X-Google-Smtp-Source: ALg8bN45TxRX96CDgOMzDQ4e26+avbKoOu86w6QKo9ceky9OXr41ZRQuiOXR+cY8TQAMtcaY0E7H
X-Received: by 2002:a17:906:f146:: with SMTP id gw6mr28322304ejb.176.1548885125496;
        Wed, 30 Jan 2019 13:52:05 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548885125; cv=none;
        d=google.com; s=arc-20160816;
        b=zyTlaZ+Brm7brn8eWRyO+JIwQn7IE2qwCMKkSNHGiWezHODVdvGi6rvu5ec2s5royH
         x15d+mBHSb0LNojDREUjzMRPp/6hVCW2F3LKkgE7Gf+dOoheI0pz7GrJKHneEIG8svmQ
         AZ/B23vMcWVEkusYD+ZschlX1X1dtnnUqSf74umYHSFzWySI4ZbdgW6ngGN9Alemp8O+
         h+6hcqueoO3jxw57VIvJD/lbt3ZOqdF2O2iyWDEGLuRI98k22+IzcBL5DoxF7ECtrQY9
         mAyhW9kp1UED0NKsvv5gX/tX/vNa13p+gNgGJUhaFnztZ8Dd5S4i6RB82OENTVnGYHI+
         2Prg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=zxSGNaFIVoRstPCm1KhTV/yJY1B7kx/Nhz8PiuhkOZs=;
        b=r6WNLYS4FnQ6sfDJuXOBlnUZ9Oz5sO1+7bBJroLzpJ3DwbJYwJ2fR1L99dyQpCJ+f0
         hQsUED8HjQEBpLwfWSNRsAZk4xdDxi+o1ooW47+LlV002o5G5ONkZF/JFjb72nTA2m4z
         OenuLOsLk+iXd5BIpbLMPkRI2a5XV/G4KUeYEy3qU2u1KsW0KudDoQ2T/6GWrWHBlx7c
         nxL8+SBEHnf6ovgkvmQAg/kWqQgZn1VZXCC7XVnTeV9/4L0oto4ovkoHO+6wDEFwqSfO
         yPqVgd5UfiPEKlC/r4OuDuwFuuRv8rew0bIm1OH7ePe/kUEjU+lV1qxXCkfHlSi7KiRG
         OH+w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from suse.de (charybdis-ext.suse.de. [195.135.221.2])
        by mx.google.com with ESMTP id e3si1462910edj.200.2019.01.30.13.52.05
        for <linux-mm@kvack.org>;
        Wed, 30 Jan 2019 13:52:05 -0800 (PST)
Received-SPF: pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) client-ip=195.135.221.2;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: by suse.de (Postfix, from userid 1000)
	id 59CB540DF; Wed, 30 Jan 2019 22:52:04 +0100 (CET)
Date: Wed, 30 Jan 2019 22:52:04 +0100
From: Oscar Salvador <osalvador@suse.de>
To: linux-mm@kvack.org
Cc: mhocko@suse.com, dan.j.williams@intel.com, Pavel.Tatashin@microsoft.com,
	david@redhat.com, linux-kernel@vger.kernel.org,
	dave.hansen@intel.com
Subject: Re: [RFC PATCH v2 0/4] mm, memory_hotplug: allocate memmap from
 hotadded memory
Message-ID: <20190130215159.culyc2wcgocp5l2p@d104.suse.de>
References: <20190122103708.11043-1-osalvador@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190122103708.11043-1-osalvador@suse.de>
User-Agent: NeoMutt/20170421 (1.8.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jan 22, 2019 at 11:37:04AM +0100, Oscar Salvador wrote:
> I yet have to check a couple of things like creating an accounting item
> like VMEMMAP_PAGES to show in /proc/meminfo to ease to spot the memory that
> went in there, testing Hyper-V/Xen to see how they react to the fact that
> we are using the beginning of the memory-range for our own purposes, and to
> check the thing about gigantic pages + hotplug.
> I also have to check that there is no compilation/runtime errors when
> CONFIG_SPARSEMEM but !CONFIG_SPARSEMEM_VMEMMAP.
> But before that, I would like to get people's feedback about the overall
> design, and ideas/suggestions.

just a friendly reminder if some feedback is possible :-)

-- 
Oscar Salvador
SUSE L3

