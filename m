Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 1487B6003A9
	for <linux-mm@kvack.org>; Tue, 29 Sep 2009 10:00:33 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 6452A82C8EB
	for <linux-mm@kvack.org>; Tue, 29 Sep 2009 10:29:54 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.253])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id eFd7DvGpedwG for <linux-mm@kvack.org>;
	Tue, 29 Sep 2009 10:29:54 -0400 (EDT)
Received: from gentwo.org (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 9E6B882C906
	for <linux-mm@kvack.org>; Tue, 29 Sep 2009 10:29:49 -0400 (EDT)
Date: Tue, 29 Sep 2009 10:22:16 -0400 (EDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: No more bits in vm_area_struct's vm_flags.
In-Reply-To: <20090929105735.06eea1ee.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <alpine.DEB.1.10.0909291019100.15549@gentwo.org>
References: <4AB9A0D6.1090004@crca.org.au> <20090924100518.78df6b93.kamezawa.hiroyu@jp.fujitsu.com> <4ABC80B0.5010100@crca.org.au> <20090925174009.79778649.kamezawa.hiroyu@jp.fujitsu.com> <4AC0234F.2080808@crca.org.au> <20090928120450.c2d8a4e2.kamezawa.hiroyu@jp.fujitsu.com>
 <20090928033624.GA11191@localhost> <20090928125705.6656e8c5.kamezawa.hiroyu@jp.fujitsu.com> <Pine.LNX.4.64.0909281637160.25798@sister.anvils> <a0ea21a7cfe313202e2b51510aa5435a.squirrel@webmail-b.css.fujitsu.com> <Pine.LNX.4.64.0909282134100.11529@sister.anvils>
 <20090929105735.06eea1ee.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Hugh Dickins <hugh.dickins@tiscali.co.uk>, Wu Fengguang <fengguang.wu@intel.com>, Nigel Cunningham <ncunningham@crca.org.au>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>


Another concern that has not been discussed is the increased cache
footprint due to a slightly enlarged vm data working set (there is also a
corresponding icache issue since additional accesses are needed).

Could we stick with the current size and do combinations of flags like we
do with page flags? VM_HUGETLB cannot grow up and down f.e. and there are
certainly lots of other impossible combinations that can be used to put
more information into the flags.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
