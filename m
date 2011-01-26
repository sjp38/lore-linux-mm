Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 266768D003A
	for <linux-mm@kvack.org>; Wed, 26 Jan 2011 11:57:06 -0500 (EST)
Date: Wed, 26 Jan 2011 10:56:56 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 1/3] Move zone_reclaim() outside of CONFIG_NUMA (v4)
In-Reply-To: <20110125050430.13141.21260.stgit@localhost6.localdomain6>
Message-ID: <alpine.DEB.2.00.1101261008440.23080@router.home>
References: <20110125050255.13141.688.stgit@localhost6.localdomain6> <20110125050430.13141.21260.stgit@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, npiggin@kernel.dk, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, kosaki.motohiro@jp.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>


Reviewed-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
