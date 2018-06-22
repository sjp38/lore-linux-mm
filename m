Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id E80FD6B0003
	for <linux-mm@kvack.org>; Fri, 22 Jun 2018 07:15:17 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id b8-v6so5048881qto.13
        for <linux-mm@kvack.org>; Fri, 22 Jun 2018 04:15:17 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id w131-v6si50413qkb.293.2018.06.22.04.15.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Jun 2018 04:15:16 -0700 (PDT)
From: David Howells <dhowells@redhat.com>
In-Reply-To: <20180620110921.2s4krw4zjbnfniq5@kili.mountain>
References: <20180620110921.2s4krw4zjbnfniq5@kili.mountain>
Subject: Re: [PATCH] hugetlbfs: Fix an error code in init_hugetlbfs_fs()
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-ID: <18325.1529666115.1@warthog.procyon.org.uk>
Date: Fri, 22 Jun 2018 12:15:15 +0100
Message-ID: <18326.1529666115@warthog.procyon.org.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Carpenter <dan.carpenter@oracle.com>
Cc: dhowells@redhat.com, Mike Kravetz <mike.kravetz@oracle.com>, linux-mm@kvack.org, kernel-janitors@vger.kernel.org

Dan Carpenter <dan.carpenter@oracle.com> wrote:

> We accidentally deleted the error code assignment.

Thanks.  I'll fold it into the original patch.

David
