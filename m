Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9DA596B025E
	for <linux-mm@kvack.org>; Tue, 10 Oct 2017 13:46:13 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id z50so28294723qtj.0
        for <linux-mm@kvack.org>; Tue, 10 Oct 2017 10:46:13 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id e20si1200274qtg.41.2017.10.10.10.46.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Oct 2017 10:46:13 -0700 (PDT)
Subject: Re: [PATCH 16/16] cifs: Use find_get_pages_range_tag()
References: <20171009151359.31984-1-jack@suse.cz>
 <20171009151359.31984-17-jack@suse.cz>
From: Daniel Jordan <daniel.m.jordan@oracle.com>
Message-ID: <ce33f739-7378-4b0f-206d-6f3380da5adf@oracle.com>
Date: Tue, 10 Oct 2017 13:48:24 -0400
MIME-Version: 1.0
In-Reply-To: <20171009151359.31984-17-jack@suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-cifs@vger.kernel.org, Steve French <sfrench@samba.org>

Hi Jan,

On 10/09/2017 11:13 AM, Jan Kara wrote:
> wdata_alloc_and_fillpages() needlessly iterates calls to
> find_get_pages_tag(). Also it wants only pages from given range. Make it
> use find_get_pages_range_tag().

Looks good, so

Reviewed-by: Daniel Jordan <daniel.m.jordan@oracle.com>

The rest of the v3 updates seem fine, too.

Daniel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
