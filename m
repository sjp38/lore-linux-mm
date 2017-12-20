Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id AD4966B0253
	for <linux-mm@kvack.org>; Wed, 20 Dec 2017 09:17:53 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id g12so9278778wra.2
        for <linux-mm@kvack.org>; Wed, 20 Dec 2017 06:17:53 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 30si13341207wrv.154.2017.12.20.06.17.52
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 20 Dec 2017 06:17:52 -0800 (PST)
Date: Wed, 20 Dec 2017 15:17:51 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] kfree_rcu() should use the new kfree_bulk() interface
 for freeing rcu structures
Message-ID: <20171220141751.GT4831@dhcp22.suse.cz>
References: <rao.shoaib@oracle.com>
 <1513705948-31072-1-git-send-email-rao.shoaib@oracle.com>
 <alpine.DEB.2.20.1712191332090.7876@nuc-kabylake>
 <b38f36d7-be4f-8cc4-208e-f0778077a063@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <b38f36d7-be4f-8cc4-208e-f0778077a063@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rao Shoaib <rao.shoaib@oracle.com>
Cc: Christopher Lameter <cl@linux.com>, linux-kernel@vger.kernel.org, paulmck@linux.vnet.ibm.com, brouer@redhat.com, linux-mm@kvack.org

On Tue 19-12-17 12:02:03, Rao Shoaib wrote:
> BTW -- This is my first ever patch to Linux, so I am still learning the
> etiquette.

Reading through Documentation/process/submitting-patches.rst might be
really helpful.

Good luck!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
