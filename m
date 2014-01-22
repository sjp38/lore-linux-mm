Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f182.google.com (mail-qc0-f182.google.com [209.85.216.182])
	by kanga.kvack.org (Postfix) with ESMTP id 011576B0035
	for <linux-mm@kvack.org>; Tue, 21 Jan 2014 22:04:33 -0500 (EST)
Received: by mail-qc0-f182.google.com with SMTP id c9so8203496qcz.27
        for <linux-mm@kvack.org>; Tue, 21 Jan 2014 19:04:33 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id k93si4634255qgf.5.2014.01.21.19.04.32
        for <linux-mm@kvack.org>;
        Tue, 21 Jan 2014 19:04:32 -0800 (PST)
Message-ID: <52DF353D.6050300@redhat.com>
Date: Tue, 21 Jan 2014 22:04:29 -0500
From: Ric Wheeler <rwheeler@redhat.com>
MIME-Version: 1.0
Subject: [LSF/MM TOPIC] really large storage sectors - going beyond 4096 bytes
References: <20131220093022.GV11295@suse.de>
In-Reply-To: <20131220093022.GV11295@suse.de>
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-scsi@vger.kernel.org, linux-ide@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, lsf-pc@lists.linux-foundation.org
Cc: linux-kernel@vger.kernel.org

One topic that has been lurking forever at the edges is the current 4k 
limitation for file system block sizes. Some devices in production today and 
others coming soon have larger sectors and it would be interesting to see if it 
is time to poke at this topic again.

LSF/MM seems to be pretty much the only event of the year that most of the key 
people will be present, so should be a great topic for a joint session.

Ric

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
