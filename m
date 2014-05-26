Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id 325956B0035
	for <linux-mm@kvack.org>; Mon, 26 May 2014 04:14:17 -0400 (EDT)
Received: by mail-wi0-f179.google.com with SMTP id bs8so3888324wib.6
        for <linux-mm@kvack.org>; Mon, 26 May 2014 01:14:16 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id cb14si15350306wib.27.2014.05.26.01.14.15
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 26 May 2014 01:14:15 -0700 (PDT)
Date: Mon, 26 May 2014 10:14:14 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: lshw sees 12GB RAM but system only using 8GB
Message-ID: <20140526081414.GA16685@dhcp22.suse.cz>
References: <20140525224237.GA4869@ikrg.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140525224237.GA4869@ikrg.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Doug Morse <dm@dougmorse.org>
Cc: linux-mm@kvack.org

Hi,

On Sun 25-05-14 17:42:37, Doug Morse wrote:
[...]
>     root@s3:~# dmesg | grep -n Memory:
> 
>     203:[    0.000000] Memory: 8133320K/8364800K available (7665K kernel code, 1147K rwdata, 3624K rodata, 1356K init, 1432K bss, 231480K reserved)

Could you post the full dmesg output, please?
[...]
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
