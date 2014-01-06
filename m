Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f46.google.com (mail-qa0-f46.google.com [209.85.216.46])
	by kanga.kvack.org (Postfix) with ESMTP id BF6336B0035
	for <linux-mm@kvack.org>; Mon,  6 Jan 2014 17:20:48 -0500 (EST)
Received: by mail-qa0-f46.google.com with SMTP id j5so852qaq.19
        for <linux-mm@kvack.org>; Mon, 06 Jan 2014 14:20:48 -0800 (PST)
Received: from mail-gg0-x235.google.com (mail-gg0-x235.google.com [2607:f8b0:4002:c02::235])
        by mx.google.com with ESMTPS id v5si32206884qcg.108.2014.01.06.14.20.47
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 06 Jan 2014 14:20:48 -0800 (PST)
Received: by mail-gg0-f181.google.com with SMTP id h13so43652ggd.12
        for <linux-mm@kvack.org>; Mon, 06 Jan 2014 14:20:47 -0800 (PST)
Message-ID: <52CB2C3A.3010207@gmail.com>
Date: Tue, 07 Jan 2014 06:20:42 +0800
From: Ric Wheeler <ricwheeler@gmail.com>
MIME-Version: 1.0
Subject: [LSF/MM TOPIC] [ATTEND] persistent memory progress, management of
 storage & file systems
References: <20131220093022.GV11295@suse.de>
In-Reply-To: <20131220093022.GV11295@suse.de>
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-scsi@vger.kernel.org, linux-ide@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, lsf-pc@lists.linux-foundation.org
Cc: linux-kernel@vger.kernel.org


I would like to attend this year and continue to talk about the work on enabling 
the new class of persistent memory devices. Specifically, very interested in 
talking about both using a block driver under our existing stack and also 
progress at the file system layer (adding xip/mmap tweaks to existing file 
systems and looking at new file systems).

We also have a lot of work left to do on unifying management, it would be good 
to resync on that.

Regards,

Ric

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
