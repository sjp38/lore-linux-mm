Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id D8B256B0074
	for <linux-mm@kvack.org>; Wed, 24 Oct 2012 04:38:08 -0400 (EDT)
Date: Wed, 24 Oct 2012 10:38:03 +0200
From: Julian Wollrath <jwollrath@web.de>
Subject: Re: [patch for-3.7] mm, numa: avoid setting zone_reclaim_mode
 unless a node is sufficiently distant
Message-ID: <20121024103803.5972de01@ilfaris>
In-Reply-To: <alpine.DEB.2.00.1210231853360.11290@chino.kir.corp.google.com>
References: <CAGPN=9Qx1JAr6CGO-JfoR2ksTJG_CLLZY_oBA_TFMzA_OSfiFg@mail.gmail.com>
	<20121022173315.7b0da762@ilfaris>
	<20121022214502.0fde3adc@ilfaris>
	<20121022170452.cc8cc629.akpm@linux-foundation.org>
	<alpine.LNX.2.00.1210222059120.1136@eggly.anvils>
	<20121023110434.021d100b@ilfaris>
	<CAJL_dMvUktOx9BqFm5jn2JbWbL_RWH412rdU+=rtDUvkuaPRUw@mail.gmail.com>
	<alpine.DEB.2.00.1210231541350.1221@chino.kir.corp.google.com>
	<CAJL_dMtS-rc1b3s9YZ+9Eapc21vF06aCT23GV8eMp13ZxURvBA@mail.gmail.com>
	<alpine.DEB.2.00.1210231853360.11290@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Patrik Kullman <patrik.kullman@gmail.com>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

This patch fixes the problem for me, thank you. Feal free to add a 

Tested-by: Julian Wollrath <jwollrath@web.de>


With best regards,
Julian Wollrath

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
