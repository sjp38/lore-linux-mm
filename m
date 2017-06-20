Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f199.google.com (mail-yb0-f199.google.com [209.85.213.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9CAB16B0279
	for <linux-mm@kvack.org>; Tue, 20 Jun 2017 15:48:02 -0400 (EDT)
Received: by mail-yb0-f199.google.com with SMTP id o132so21793237ybg.4
        for <linux-mm@kvack.org>; Tue, 20 Jun 2017 12:48:02 -0700 (PDT)
Received: from mail-yb0-x242.google.com (mail-yb0-x242.google.com. [2607:f8b0:4002:c09::242])
        by mx.google.com with ESMTPS id a83si890142ywe.479.2017.06.20.12.48.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Jun 2017 12:48:01 -0700 (PDT)
Received: by mail-yb0-x242.google.com with SMTP id b63so6904844yba.1
        for <linux-mm@kvack.org>; Tue, 20 Jun 2017 12:48:01 -0700 (PDT)
Date: Tue, 20 Jun 2017 15:47:59 -0400
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH] percpu_counter: Rename __percpu_counter_add to
 percpu_counter_add_batch
Message-ID: <20170620194759.GG21326@htj.duckdns.org>
References: <20170620172835.GA21326@htj.duckdns.org>
 <1497981680-6969-1-git-send-email-nborisov@suse.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1497981680-6969-1-git-send-email-nborisov@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nikolay Borisov <nborisov@suse.com>
Cc: jbacik@fb.com, linux-kernel@vger.kernel.org, mgorman@techsingularity.net, Chris Mason <clm@fb.com>, David Sterba <dsterba@suse.com>, "Darrick J. Wong" <darrick.wong@oracle.com>, Jan Kara <jack@suse.com>, Jens Axboe <axboe@fb.com>, linux-mm@kvack.org, "David S. Miller" <davem@davemloft.net>

