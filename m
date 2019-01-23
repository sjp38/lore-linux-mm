Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id 10AE28E001A
	for <linux-mm@kvack.org>; Wed, 23 Jan 2019 09:09:13 -0500 (EST)
Received: by mail-yw1-f69.google.com with SMTP id 201so1186225ywp.13
        for <linux-mm@kvack.org>; Wed, 23 Jan 2019 06:09:13 -0800 (PST)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id b194si11638756ywh.68.2019.01.23.06.09.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Jan 2019 06:09:11 -0800 (PST)
Content-Type: text/plain;
	charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 12.2 \(3445.102.3\))
Subject: Re: [PATCH 1/2] mm/mmap.c: Remove redundant variable 'addr' in
 arch_get_unmapped_area_topdown()
From: William Kucharski <william.kucharski@oracle.com>
In-Reply-To: <affba895224614ac3f2cbafa9d4fa7be3361de9d.1547966629.git.nullptr.cpp@gmail.com>
Date: Wed, 23 Jan 2019 07:09:02 -0700
Content-Transfer-Encoding: 7bit
Message-Id: <919A3677-F069-4944-9590-588D366578A1@oracle.com>
References: <cover.1547966629.git.nullptr.cpp@gmail.com>
 <affba895224614ac3f2cbafa9d4fa7be3361de9d.1547966629.git.nullptr.cpp@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Fan <nullptr.cpp@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, will.deacon@arm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org



> On Jan 20, 2019, at 1:13 AM, Yang Fan <nullptr.cpp@gmail.com> wrote:
> 
> The variable 'addr' is redundant in arch_get_unmapped_area_topdown(), 
> just use parameter 'addr0' directly. Then remove the const qualifier 
> of the parameter, and change its name to 'addr'.
> 
> Signed-off-by: Yang Fan <nullptr.cpp@gmail.com>

These seem similar enough I question whether they really need to be two
distinct patches, given both involve removing const keywords from the same
routine, and the shift to using the passed addr directly rather than
declaring and assigning addr from addr0 is a direct consequence of
removing the const.

I could be wrong though and easily persuaded otherwise.
