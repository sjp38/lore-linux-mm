Received: from pcp by pcp.eaters.net with local (Exim 3.22 #5)
	id 14bl9h-00004Z-00
	for linux-mm@kvack.org; Sat, 10 Mar 2001 16:19:41 +0100
Date: Sat, 10 Mar 2001 16:19:40 +0100
From: pcp <da.box@home.se>
Subject: aic7xxx
Message-ID: <20010310161940.A280@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

hi...i have an adaptec scsi host that uses aic7xxx....it's been working
fine up until linux-2.4.2-ac12 but when i moved to linux-2.4.2-ac15 it
won't find my scsi devices (a cd-r burner)....what might have changed to
make this happen? both use the new aic7xxx drivers as far as i can
understand (their filesize is even the same in both versions)...

-- 
/*
 * Name:        Nikolai Weibull
 * Nicks:       pcp, pcppopper
 * System:      Midi ATX, ASUS CUV4X, Celeron 667@950, GeForce2 MX 32,
 *              256mb PC133, Fujitsu 20.49gb UDMA-66
 * E-Mail:      da.box@home.se
 * E-Location:  www.pcppopper.org
 */
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
