Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id A48B36B44BB
	for <linux-mm@kvack.org>; Mon, 26 Nov 2018 19:33:39 -0500 (EST)
Received: by mail-io1-f70.google.com with SMTP id f24so20162525ioh.21
        for <linux-mm@kvack.org>; Mon, 26 Nov 2018 16:33:39 -0800 (PST)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id 71si1970371itr.123.2018.11.26.16.33.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Nov 2018 16:33:38 -0800 (PST)
Content-Type: text/plain;
	charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 12.2 \(3445.102.3\))
Subject: Re: [RFC PATCH 3/3] mm, proc: report PR_SET_THP_DISABLE in proc
From: William Kucharski <william.kucharski@oracle.com>
In-Reply-To: <20181120103515.25280-4-mhocko@kernel.org>
Date: Mon, 26 Nov 2018 17:33:32 -0700
Content-Transfer-Encoding: quoted-printable
Message-Id: <0ACDD94B-75AD-4DD0-B2E3-32C0EDFBAA5E@oracle.com>
References: <20181120103515.25280-1-mhocko@kernel.org>
 <20181120103515.25280-4-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-api@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Alexey Dobriyan <adobriyan@gmail.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>



This determines whether the page can theoretically be THP-mapped , but =
is the intention to also check for proper alignment and/or preexisting =
PAGESIZE page cache mappings for the address range?

I'm having to deal with both these issues in the text page THP prototype =
I've been working on for some time now.

    Thanks,
         William Kucharski=
