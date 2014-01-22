Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f178.google.com (mail-ie0-f178.google.com [209.85.223.178])
	by kanga.kvack.org (Postfix) with ESMTP id 0910A6B0035
	for <linux-mm@kvack.org>; Wed, 22 Jan 2014 15:47:20 -0500 (EST)
Received: by mail-ie0-f178.google.com with SMTP id x13so78650ief.37
        for <linux-mm@kvack.org>; Wed, 22 Jan 2014 12:47:19 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id 9si16080095igo.72.2014.01.22.12.47.18
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 22 Jan 2014 12:47:18 -0800 (PST)
Subject: Re: [Lsf-pc] [LSF/MM TOPIC] really large storage sectors - going beyond 4096 bytes
From: "Martin K. Petersen" <martin.petersen@oracle.com>
References: <20131220093022.GV11295@suse.de> <52DF353D.6050300@redhat.com>
	<20140122093435.GS4963@suse.de> <52DFD168.8080001@redhat.com>
	<20140122143452.GW4963@suse.de> <52DFDCA6.1050204@redhat.com>
Date: Wed, 22 Jan 2014 15:47:12 -0500
In-Reply-To: <52DFDCA6.1050204@redhat.com> (Ric Wheeler's message of "Wed, 22
	Jan 2014 09:58:46 -0500")
Message-ID: <yq138kfbv73.fsf@sermon.lab.mkp.net>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ric Wheeler <rwheeler@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>, linux-scsi@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-ide@vger.kernel.org, linux-fsdevel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, lsf-pc@lists.linux-foundation.org

>>>>> "Ric" == Ric Wheeler <rwheeler@redhat.com> writes:

Ric> I will have to see if I can get a storage vendor to make a public
Ric> statement, but there are vendors hoping to see this land in Linux
Ric> in the next few years. I assume that anyone with a shipping device
Ric> will have to at least emulate the 4KB sector size for years to
Ric> come, but that there might be a significant performance win for
Ric> platforms that can do a larger block.

I am aware of two companies that already created devices with 8KB
logical blocks and expected Linux to work. I had to do some explaining.

I agree with Ric that this is something we'll need to address sooner
rather than later.

-- 
Martin K. Petersen	Oracle Linux Engineering

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
