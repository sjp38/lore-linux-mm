Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb1-f200.google.com (mail-yb1-f200.google.com [209.85.219.200])
	by kanga.kvack.org (Postfix) with ESMTP id 70A986B2415
	for <linux-mm@kvack.org>; Tue, 20 Nov 2018 23:51:53 -0500 (EST)
Received: by mail-yb1-f200.google.com with SMTP id h141-v6so2350729ybg.17
        for <linux-mm@kvack.org>; Tue, 20 Nov 2018 20:51:53 -0800 (PST)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id a9-v6si27961484yba.160.2018.11.20.20.51.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Nov 2018 20:51:52 -0800 (PST)
Content-Type: text/plain;
	charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 12.2 \(3445.102.3\))
Subject: Re: [RFC PATCH 3/3] mm, fault_around: do not take a reference to a
 locked page
From: William Kucharski <william.kucharski@oracle.com>
In-Reply-To: <20181120141207.GK22247@dhcp22.suse.cz>
Date: Tue, 20 Nov 2018 21:51:39 -0700
Content-Transfer-Encoding: 7bit
Message-Id: <29F15A96-D6EB-450E-B54B-A4CB460ED9B3@oracle.com>
References: <20181120134323.13007-1-mhocko@kernel.org>
 <20181120134323.13007-4-mhocko@kernel.org>
 <20181120140715.mouc7okin3ht5krr@kshutemo-mobl1>
 <20181120141207.GK22247@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Linux-MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Oscar Salvador <OSalvador@suse.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, David Hildenbrand <david@redhat.com>, LKML <linux-kernel@vger.kernel.org>



> On Nov 20, 2018, at 7:12 AM, Michal Hocko <mhocko@kernel.org> wrote:
> 
> +		/*
> +		 * Check the locked pages before taking a reference to not
> +		 * go in the way of migration.
> +		 */

Could you make this a tiny bit more explanative, something like:

+		/*
+		 * Check for a locked page first, as a speculative
+		 * reference may adversely influence page migration.
+		 */

Reviewed-by: William Kucharski <william.kucharski@oracle.com>
