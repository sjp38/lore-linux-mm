Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 79B876B0003
	for <linux-mm@kvack.org>; Tue, 10 Apr 2018 19:52:25 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id o66-v6so355765ita.3
        for <linux-mm@kvack.org>; Tue, 10 Apr 2018 16:52:25 -0700 (PDT)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id 204si2669435ioz.231.2018.04.10.16.52.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Apr 2018 16:52:24 -0700 (PDT)
Subject: Re: [PATCH v3 2/3] mm/shmem: update file sealing comments and file
 checking
References: <20180409230505.18953-1-mike.kravetz@oracle.com>
 <20180409230505.18953-3-mike.kravetz@oracle.com>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <b03b3f04-638f-2262-8bda-2291ea8cad26@oracle.com>
Date: Tue, 10 Apr 2018 16:51:56 -0700
MIME-Version: 1.0
In-Reply-To: <20180409230505.18953-3-mike.kravetz@oracle.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Matthew Wilcox <willy@infradead.org>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@kernel.org>, =?UTF-8?Q?Marc-Andr=c3=a9_Lureau?= <marcandre.lureau@gmail.com>, David Herrmann <dh.herrmann@gmail.com>, Khalid Aziz <khalid.aziz@oracle.com>, Andrew Morton <akpm@linux-foundation.org>

In response to Matthew's question about patch 3, I went back and cleaned
up all comments, definitions and function names that will be moved to the
new memfd files.  No functional changes from previous version.  This will
require a new version of patch 3.
