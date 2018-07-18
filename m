Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id B83006B0287
	for <linux-mm@kvack.org>; Wed, 18 Jul 2018 06:37:13 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id r9-v6so1762527edh.14
        for <linux-mm@kvack.org>; Wed, 18 Jul 2018 03:37:13 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x6-v6si734188eds.237.2018.07.18.03.37.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Jul 2018 03:37:12 -0700 (PDT)
Date: Wed, 18 Jul 2018 12:37:09 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: mmap with huge page
Message-ID: <20180718103709.GB1431@dhcp22.suse.cz>
References: <115606142.5883850.1531854314452.ref@mail.yahoo.com>
 <115606142.5883850.1531854314452@mail.yahoo.com>
 <3b40325e-a75e-017d-920e-83e090153621@oracle.com>
 <1485529317.61381.1531872070328@mail.yahoo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1485529317.61381.1531872070328@mail.yahoo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Frank <david_frank95@yahoo.com>
Cc: Kernelnewbies <kernelnewbies@kernelnewbies.org>, Linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mike Kravetz <mike.kravetz@oracle.com>

On Wed 18-07-18 00:01:10, David Frank wrote:
>  Thanks Mike.  I read the doc, which is not explicit on the non used file taking up huge page count 

What do you consider non user file? The file contains a data somebody
might want to read later. You cannot simply remove it. This is not
different to any other in memory filesystem (e.g. tmpfs, ramfs)
-- 
Michal Hocko
SUSE Labs
