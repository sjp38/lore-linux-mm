Received: from westrelay03.boulder.ibm.com (westrelay03.boulder.ibm.com [9.17.195.12])
	by e35.co.us.ibm.com (8.12.10/8.12.9) with ESMTP id j1FKsYLg560298
	for <linux-mm@kvack.org>; Tue, 15 Feb 2005 15:54:34 -0500
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by westrelay03.boulder.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j1FKsVZN362850
	for <linux-mm@kvack.org>; Tue, 15 Feb 2005 13:54:34 -0700
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11/8.12.11) with ESMTP id j1FKsVos031914
	for <linux-mm@kvack.org>; Tue, 15 Feb 2005 13:54:31 -0700
Subject: Re: [RFC 2.6.11-rc2-mm2 7/7] mm: manual page migration --
	sys_page_migrate
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <20050215185943.GA24401@lnx-holt.americas.sgi.com>
References: <20050212032535.18524.12046.26397@tomahawk.engr.sgi.com>
	 <20050212032620.18524.15178.29731@tomahawk.engr.sgi.com>
	 <1108242262.6154.39.camel@localhost>
	 <20050214135221.GA20511@lnx-holt.americas.sgi.com>
	 <1108407043.6154.49.camel@localhost>
	 <20050214220148.GA11832@lnx-holt.americas.sgi.com>
	 <20050215074906.01439d4e.pj@sgi.com>
	 <20050215162135.GA22646@lnx-holt.americas.sgi.com>
	 <20050215083529.2f80c294.pj@sgi.com>
	 <20050215185943.GA24401@lnx-holt.americas.sgi.com>
Content-Type: text/plain
Date: Tue, 15 Feb 2005 12:54:22 -0800
Message-Id: <1108500863.16958.1.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Robin Holt <holt@sgi.com>
Cc: Paul Jackson <pj@sgi.com>, Ray Bryant <raybry@sgi.com>, Hirokazu Takahashi <taka@valinux.co.jp>, hugh@veritas.com, Andrew Morton <akpm@osdl.org>, marcello@cyclades.com, raybry@austin.rr.com, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

In the interest of the size of everyone's inboxes, I mentioned to Ray
that we might move this discussion to a smaller forum while we resolve
some of the outstanding issues.  Ray's going to post a followup to to
linux-mm, and trim the cc list down.  So, if you're still interested,
keep your eyes on linux-mm and we'll continue there.  

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
