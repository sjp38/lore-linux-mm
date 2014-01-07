Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f52.google.com (mail-wg0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 392B46B0031
	for <linux-mm@kvack.org>; Tue,  7 Jan 2014 14:44:32 -0500 (EST)
Received: by mail-wg0-f52.google.com with SMTP id b13so333129wgh.31
        for <linux-mm@kvack.org>; Tue, 07 Jan 2014 11:44:31 -0800 (PST)
Received: from ZenIV.linux.org.uk (zeniv.linux.org.uk. [2002:c35c:fd02::1])
        by mx.google.com with ESMTPS id kn2si29372572wjc.172.2014.01.07.11.44.31
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 07 Jan 2014 11:44:31 -0800 (PST)
Date: Tue, 7 Jan 2014 11:44:25 -0800
From: Joel Becker <jlbec@evilplan.org>
Subject: Re: [LSF/MM TOPIC] [ATTEND] persistent memory progress, management
 of storage & file systems
Message-ID: <20140107194424.GN5272@localhost>
References: <20131220093022.GV11295@suse.de>
 <52CB2C3A.3010207@gmail.com>
 <2512424DBC01FD48843E938C780FA97C02B002A583@MX23A.corp.emc.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <2512424DBC01FD48843E938C780FA97C02B002A583@MX23A.corp.emc.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "faibish, sorin" <faibish_sorin@emc.com>
Cc: Ric Wheeler <ricwheeler@gmail.com>, "linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>, "linux-ide@vger.kernel.org" <linux-ide@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "lsf-pc@lists.linux-foundation.org" <lsf-pc@lists.linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Mon, Jan 06, 2014 at 05:32:56PM -0500, faibish, sorin wrote:
> Speaking of persistent memory I would like to discuss the PMFS as well as RDMA aspects of the persistent memory model. Also I would like to discuss KV stores and object stores on persistent memory. I was involved in the PMFS as a tester and I found several issues that I would like to discuss with the community. I assume that maybe others from Intel could join this discussion except for Andy and Matt which already asked for this topic. Thanks

Ooh, and the cluster/remote filesystem stories there (eg, RDMA etc) are
probably pretty cool.

Joel

> 
> ./Sorin
> 
> -----Original Message-----
> From: linux-fsdevel-owner@vger.kernel.org [mailto:linux-fsdevel-owner@vger.kernel.org] On Behalf Of Ric Wheeler
> Sent: Monday, January 06, 2014 5:21 PM
> To: linux-scsi@vger.kernel.org; linux-ide@vger.kernel.org; linux-mm@kvack.org; linux-fsdevel@vger.kernel.org; lsf-pc@lists.linux-foundation.org
> Cc: linux-kernel@vger.kernel.org
> Subject: [LSF/MM TOPIC] [ATTEND] persistent memory progress, management of storage & file systems
> 
> 
> I would like to attend this year and continue to talk about the work on enabling the new class of persistent memory devices. Specifically, very interested in talking about both using a block driver under our existing stack and also progress at the file system layer (adding xip/mmap tweaks to existing file systems and looking at new file systems).
> 
> We also have a lot of work left to do on unifying management, it would be good to resync on that.
> 
> Regards,
> 
> Ric
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-fsdevel" in the body of a message to majordomo@vger.kernel.org More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

-- 

 The herd instinct among economists makes sheep look like
 independant thinkers.

			http://www.jlbec.org/
			jlbec@evilplan.org

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
