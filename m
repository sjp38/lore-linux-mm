Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f45.google.com (mail-pb0-f45.google.com [209.85.160.45])
	by kanga.kvack.org (Postfix) with ESMTP id CC4816B0037
	for <linux-mm@kvack.org>; Mon, 23 Sep 2013 10:52:56 -0400 (EDT)
Received: by mail-pb0-f45.google.com with SMTP id mc17so3293209pbc.4
        for <linux-mm@kvack.org>; Mon, 23 Sep 2013 07:52:56 -0700 (PDT)
Received: by mail-vb0-f43.google.com with SMTP id h11so2362048vbh.30
        for <linux-mm@kvack.org>; Mon, 23 Sep 2013 07:52:49 -0700 (PDT)
Date: Mon, 23 Sep 2013 10:52:46 -0400
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH] percpu: fix bootmem error handling in pcpu_page_first_chunk()
Message-ID: <20130923145246.GA14547@htj.dyndns.org>
References: <20130917165734.16aa0226@holzheu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130917165734.16aa0226@holzheu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michael Holzheu <holzheu@linux.vnet.ibm.com>
Cc: Christoph Lameter <cl@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Applied to percpu/for-3.12-fixes with the if conditional flipped.

Thanks!

----- 8< ------
