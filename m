Return-Path: <SRS0=i6a/=S4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CC383C43218
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 13:59:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9798821479
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 13:59:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9798821479
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 311BF6B0003; Fri, 26 Apr 2019 09:59:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2C0F76B0005; Fri, 26 Apr 2019 09:59:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 189076B0006; Fri, 26 Apr 2019 09:59:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id BF2A46B0003
	for <linux-mm@kvack.org>; Fri, 26 Apr 2019 09:59:17 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id s21so1570162edd.10
        for <linux-mm@kvack.org>; Fri, 26 Apr 2019 06:59:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=/Rgruo12HANQEAsCQCr9iioNBVtY8Y+9VFWf2lzjo9s=;
        b=UF1T4nJuuK1MnW8U5OwZcvEaAXzqbCqtScZjnbdH2Fpc32yYwW+l7Gljl5lGeL9isu
         59yOGCagP+aDa9NWh2s6DX0lv9mrc7FGjEHWhgXBpZjjT+Dx2QlMUY/Nw0/irV3J8Aul
         O/SYXtFSPvZYuQ77FnQPk4787fSbM7jbQ1zQhcwdepUyUaTxV66xa9+aUzxB/KXJgd/w
         6S27HxJ6Y65Bs0zDTW4u4EOTWqluZ3fxFHjljejql8uK/dz+85P4ZD8mSnO3rLvv1U4k
         CcJ8vhagJWH+oTQ+qkVfHZjej6orxD6zbpLEydhC5gN8WQAxHe1A4dw0Bd8eEK5tILOr
         tXTw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: APjAAAUy/3VZ6PL5WxP4qTHuaaMjG7G7GEmLO1IrjSngMSutvXL5UMHZ
	rH0BfiOWWAXBerpp/F7gUwa1X1AH/5/Yvx6kNFlow0N2d+G9TR80p0lXgNencMN5T6zq3IRGexM
	t07Anf/t+d69/vtTpLpqexf0BDLpJNyySWixKlnK3ZOiwKLJ88MEHCW5JvyEtl3Vu6A==
X-Received: by 2002:a50:9097:: with SMTP id c23mr29078949eda.119.1556287157347;
        Fri, 26 Apr 2019 06:59:17 -0700 (PDT)
X-Google-Smtp-Source: APXvYqww3uzmSBttr9fvpfsVTTfpvmWBHZGBd5zxM/tLI5lrT8gppTliNe2GQuDS2d8w/z4lgA9Z
X-Received: by 2002:a50:9097:: with SMTP id c23mr29078911eda.119.1556287156659;
        Fri, 26 Apr 2019 06:59:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556287156; cv=none;
        d=google.com; s=arc-20160816;
        b=W11mX9tX47REXFRO4g/Md1FU0GrV+RrIkbnsgyUln3fVlprVlWcMsbyGTOQ273r0sP
         I8t9Q1PZduyXt83RnIAPf0Akz8Nib0ijRhEYtuD5nKWNvCyIJbZNAamc5BrAJ1Woctu7
         hghu7NE2YgHXotZgGPJvAfAM7vpjqWA+sPSPEOmFdNJ/lyIXUL1oTwAb7gMqUS3KnHTz
         t8FT1tnpBWOPuWmPYWoheINchibjvVQt8ZeGzRoIz0LQVfBGCGdUtl2YwOWl1Qnx2sUp
         lXtmGa7TPS4Cf9tBvO/NpXrhVKbQY+9LdIubsbRIjYo0zN4DFVDhrhpL+xAF2i23vFjp
         KwKg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=/Rgruo12HANQEAsCQCr9iioNBVtY8Y+9VFWf2lzjo9s=;
        b=flEkZy6C99+uCrSjy0K/bIsUhjXioqIn+CEl0PspGK0R8j1/nmrRvn6vqlk+QsqZzA
         l3QQ49wNXLUCaiukPFtG6bQACGogKJBXq0L8rdwBgwudjQlfwAGrhljekFpYT7VToar3
         5DBjmB4dZNJNAedHsi7xlBFhiR0BU85Xl1PRRUqdmrIUd6Kx2SQtrAkEbuVNbCaev6y9
         jdVfM+6Zggaim7w9EJUczVtbnm9ocPgtc23Is4p3Eg49QzX1NsxUA06fcK80nRmVpI/B
         stDHLU5WSgILPa/zmERzVxpuZoenBepFXzT5RY7/81bhmrFymfi398jTVE5YPIDNMVlM
         6uDA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m27si2300139edc.433.2019.04.26.06.59.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Apr 2019 06:59:16 -0700 (PDT)
Received-SPF: pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id B9654AEC2;
	Fri, 26 Apr 2019 13:59:15 +0000 (UTC)
Date: Fri, 26 Apr 2019 15:59:12 +0200
From: Oscar Salvador <osalvador@suse.de>
To: Dan Williams <dan.j.williams@intel.com>
Cc: akpm@linux-foundation.org, Michal Hocko <mhocko@suse.com>,
	Vlastimil Babka <vbabka@suse.cz>,
	Logan Gunthorpe <logang@deltatee.com>, linux-mm@kvack.org,
	linux-nvdimm@lists.01.org, linux-kernel@vger.kernel.org,
	david@redhat.com
Subject: Re: [PATCH v6 04/12] mm/hotplug: Prepare shrink_{zone, pgdat}_span
 for sub-section removal
Message-ID: <20190426135907.GA30513@linux>
References: <155552633539.2015392.2477781120122237934.stgit@dwillia2-desk3.amr.corp.intel.com>
 <155552635609.2015392.6246305135559796835.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <155552635609.2015392.6246305135559796835.stgit@dwillia2-desk3.amr.corp.intel.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 17, 2019 at 11:39:16AM -0700, Dan Williams wrote:
> @@ -417,10 +417,10 @@ static void shrink_zone_span(struct zone *zone, unsigned long start_pfn,
>  	 * it check the zone has only hole or not.
>  	 */
>  	pfn = zone_start_pfn;
> -	for (; pfn < zone_end_pfn; pfn += PAGES_PER_SECTION) {
> +	for (; pfn < zone_end_pfn; pfn += PAGES_PER_SUB_SECTION) {
>  		ms = __pfn_to_section(pfn);
>  
> -		if (unlikely(!valid_section(ms)))
> +		if (unlikely(!pfn_valid(pfn)))
>  			continue;
>  
>  		if (page_zone(pfn_to_page(pfn)) != zone)
> @@ -485,10 +485,10 @@ static void shrink_pgdat_span(struct pglist_data *pgdat,
>  	 * has only hole or not.
>  	 */
>  	pfn = pgdat_start_pfn;
> -	for (; pfn < pgdat_end_pfn; pfn += PAGES_PER_SECTION) {
> +	for (; pfn < pgdat_end_pfn; pfn += PAGES_PER_SUB_SECTION) {
>  		ms = __pfn_to_section(pfn);
>  
> -		if (unlikely(!valid_section(ms)))
> +		if (unlikely(!pfn_valid(pfn)))
>  			continue;
>  
>  		if (pfn_to_nid(pfn) != nid)

The last loop from shrink_{pgdat,zone}_span can be reworked to unify both
in one function, and both functions can be factored out a bit.
Actually, I do have a patch that does that, I might dig it up.

The rest looks good:

Reviewed-by: Oscar Salvador <osalvador@suse.de>

> 

-- 
Oscar Salvador
SUSE L3

