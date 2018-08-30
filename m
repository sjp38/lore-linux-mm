Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3263A6B51B4
	for <linux-mm@kvack.org>; Thu, 30 Aug 2018 12:19:45 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id j22-v6so6232425wre.7
        for <linux-mm@kvack.org>; Thu, 30 Aug 2018 09:19:45 -0700 (PDT)
Received: from cloud1-vm154.de-nserver.de (cloud1-vm154.de-nserver.de. [178.250.10.56])
        by mx.google.com with ESMTPS id x17-v6si6022986wrm.46.2018.08.30.09.19.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 30 Aug 2018 09:19:44 -0700 (PDT)
Content-Type: multipart/alternative;
	boundary=Apple-Mail-0735E658-3004-419F-B561-1A58A0795CA2
Mime-Version: 1.0 (1.0)
Subject: Re: [PATCH] mm, thp: relax __GFP_THISNODE for MADV_HUGEPAGE mappings
From: Stefan Priebe - Profihost AG <s.priebe@profihost.ag>
In-Reply-To: <C0146217-821B-4530-A2E2-57D4CCDE8102@cs.rutgers.edu>
Date: Thu, 30 Aug 2018 18:19:40 +0200
Content-Transfer-Encoding: 7bit
Message-Id: <4040814A-C83A-4EEB-97A4-280756695456@profihost.ag>
References: <20180829142816.GX10223@dhcp22.suse.cz> <20180829143545.GY10223@dhcp22.suse.cz> <82CA00EB-BF8E-4137-953B-8BC4B74B99AF@cs.rutgers.edu> <20180829154744.GC10223@dhcp22.suse.cz> <39BE14E6-D0FB-428A-B062-8B5AEDC06E61@cs.rutgers.edu> <20180829162528.GD10223@dhcp22.suse.cz> <20180829192451.GG10223@dhcp22.suse.cz> <E97C9342-9BA0-48DD-A580-738ACEE49B41@cs.rutgers.edu> <20180830070021.GB2656@dhcp22.suse.cz> <4AFDF557-46E3-4C62-8A43-C28E8F2A54CF@cs.rutgers.edu> <20180830134549.GI2656@dhcp22.suse.cz> <C0146217-821B-4530-A2E2-57D4CCDE8102@cs.rutgers.edu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zi Yan <zi.yan@cs.rutgers.edu>
Cc: Michal Hocko <mhocko@suse.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Alex Williamson <alex.williamson@redhat.com>, David Rientjes <rientjes@google.com>, Vlastimil Babka <vbabka@suse.cz>


--Apple-Mail-0735E658-3004-419F-B561-1A58A0795CA2
Content-Type: text/plain;
	charset=us-ascii
Content-Transfer-Encoding: 7bit

Please add also:
Tested-by: Stefan Priebe <s.priebe@profihost.ag>

Stefan

Excuse my typo sent from my mobile phone.

> Am 30.08.2018 um 16:02 schrieb Zi Yan <zi.yan@cs.rutgers.edu>:
> 
> Tested-by: Zi Yan <zi.yan@cs.rutgers.edu>

--Apple-Mail-0735E658-3004-419F-B561-1A58A0795CA2
Content-Type: text/html;
	charset=utf-8
Content-Transfer-Encoding: 7bit

<html><head><meta http-equiv="content-type" content="text/html; charset=utf-8"></head><body dir="auto">Please add also:<div><span style="background-color: rgba(255, 255, 255, 0);">Tested-by: Stefan Priebe &lt;<a href="mailto:s.priebe@profihost.ag">s.priebe@profihost.ag</a>&gt;</span></div><div><br><div id="AppleMailSignature">Stefan<div><br></div><div>Excuse my typo s<span style="font-size: 13pt;">ent from my mobile phone.</span></div></div><div><br>Am 30.08.2018 um 16:02 schrieb Zi Yan &lt;<a href="mailto:zi.yan@cs.rutgers.edu">zi.yan@cs.rutgers.edu</a>&gt;:<br><br></div><blockquote type="cite"><div>Tested-by: Zi Yan &lt;<span><a href="mailto:zi.yan@cs.rutgers.edu">zi.yan@cs.rutgers.edu</a></span>&gt;</div></blockquote></div></body></html>
--Apple-Mail-0735E658-3004-419F-B561-1A58A0795CA2--
