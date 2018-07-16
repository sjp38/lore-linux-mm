Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 165746B0006
	for <linux-mm@kvack.org>; Mon, 16 Jul 2018 12:45:03 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id g11-v6so882947edi.8
        for <linux-mm@kvack.org>; Mon, 16 Jul 2018 09:45:03 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x39-v6si5569378ede.200.2018.07.16.09.45.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Jul 2018 09:45:02 -0700 (PDT)
Date: Mon, 16 Jul 2018 18:45:00 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Caching/buffers become useless after some time
Message-ID: <20180716164500.GZ17280@dhcp22.suse.cz>
References: <CADF2uSrW=Z=7NeA4qRwStoARGeT1y33QSP48Loc1u8XSdpMJOA@mail.gmail.com>
 <20180712113411.GB328@dhcp22.suse.cz>
 <CADF2uSqDDt3X_LHEQnc5xzHpqJ66E5gncogwR45bmZsNHxV55A@mail.gmail.com>
 <CADF2uSr-uFz+AAhcwP7ORgGgtLohayBtpDLxx9kcADDxaW8hWw@mail.gmail.com>
 <20180716162337.GY17280@dhcp22.suse.cz>
 <CADF2uSpEZTqD7pUp1t77GNTT+L=M3Ycir2+gsZg3kf5=y-5_-Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CADF2uSpEZTqD7pUp1t77GNTT+L=M3Ycir2+gsZg3kf5=y-5_-Q@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marinko Catovic <marinko.catovic@gmail.com>
Cc: linux-mm@kvack.org

On Mon 16-07-18 18:33:57, Marinko Catovic wrote:
> how periodically do you want them? I assumed this some-hours and days
> snapshots would be sufficient.

Every 10s should be reasonable even for a long term monitoring.

> any particular command with or without grep perhaps?

while true
do
	cp /proc/vmstat vmstat.$(date +%s)
	sleep 10s
done
-- 
Michal Hocko
SUSE Labs
