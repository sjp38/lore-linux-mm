Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 146246B0007
	for <linux-mm@kvack.org>; Wed,  4 Jul 2018 08:36:30 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id f6-v6so2164144eds.6
        for <linux-mm@kvack.org>; Wed, 04 Jul 2018 05:36:30 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 38-v6si1045844edt.374.2018.07.04.05.36.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Jul 2018 05:36:28 -0700 (PDT)
Date: Wed, 4 Jul 2018 14:36:27 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2 3/3] m68k: switch to MEMBLOCK + NO_BOOTMEM
Message-ID: <20180704123627.GM22503@dhcp22.suse.cz>
References: <1530685696-14672-1-git-send-email-rppt@linux.vnet.ibm.com>
 <1530685696-14672-4-git-send-email-rppt@linux.vnet.ibm.com>
 <CAMuHMdWEHSz34bN-U3gHW972w13f_Jrx_ObEsP3w8XZ1Gx65OA@mail.gmail.com>
 <20180704075410.GF22503@dhcp22.suse.cz>
 <89f48f7a-6cbf-ac9a-cacc-cd3ca79f8c66@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <89f48f7a-6cbf-ac9a-cacc-cd3ca79f8c66@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Geert Uytterhoeven <geert@linux-m68k.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Greg Ungerer <gerg@linux-m68k.org>, Sam Creasey <sammy@sammy.net>, linux-m68k <linux-m68k@lists.linux-m68k.org>, Linux MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

[CC Andrew - email thread starts
http://lkml.kernel.org/r/1530685696-14672-1-git-send-email-rppt@linux.vnet.ibm.com]

OK, so here we go with the full patch.
