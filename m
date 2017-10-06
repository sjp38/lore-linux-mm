Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4E3276B0253
	for <linux-mm@kvack.org>; Fri,  6 Oct 2017 02:39:27 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id l188so22969590pfc.7
        for <linux-mm@kvack.org>; Thu, 05 Oct 2017 23:39:27 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id o9si634672plk.112.2017.10.05.23.39.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Oct 2017 23:39:23 -0700 (PDT)
Date: Thu, 5 Oct 2017 23:39:19 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH v5 0/5] cramfs refresh for embedded usage
Message-ID: <20171006063919.GA16556@infradead.org>
References: <20171006024531.8885-1-nicolas.pitre@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171006024531.8885-1-nicolas.pitre@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nicolas Pitre <nicolas.pitre@linaro.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Christoph Hellwig <hch@infradead.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-embedded@vger.kernel.org, linux-kernel@vger.kernel.org, Chris Brandt <Chris.Brandt@renesas.com>

This is still missing a proper API for accessing the file system,
as said before specifying a physical address in the mount command
line is a an absolute non-no.

Either work with the mtd folks to get the mtd core down to an absolute
minimum suitable for you, or figure out a way to specify fs nodes
through DT or similar.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
