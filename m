Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id 17CBA6B004F
	for <linux-mm@kvack.org>; Thu, 15 Dec 2011 14:43:47 -0500 (EST)
Received: by ggni2 with SMTP id i2so2877320ggn.14
        for <linux-mm@kvack.org>; Thu, 15 Dec 2011 11:43:46 -0800 (PST)
Date: Thu, 15 Dec 2011 11:43:41 -0800
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH] percpu: fix per_cpu_ptr_to_phys() handling of
 non-page-aligned addresses
Message-ID: <20111215194341.GG32002@google.com>
References: <20111215192559.GA28283@gate.ebshome.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111215192559.GA28283@gate.ebshome.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eugene Surovegin <ebs@ebshome.net>
Cc: ptesarik@suse.cz, xiyou.wangcong@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, vgoyal@redhat.com

