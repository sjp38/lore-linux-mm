Return-Path: <SRS0=kGB6=SG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9517AC4360F
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 21:58:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 585F520663
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 21:58:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 585F520663
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=zeniv.linux.org.uk
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E82926B000C; Thu,  4 Apr 2019 17:58:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E58EB6B000D; Thu,  4 Apr 2019 17:58:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D6E656B000E; Thu,  4 Apr 2019 17:58:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f69.google.com (mail-wm1-f69.google.com [209.85.128.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8C2B96B000C
	for <linux-mm@kvack.org>; Thu,  4 Apr 2019 17:58:45 -0400 (EDT)
Received: by mail-wm1-f69.google.com with SMTP id h13so2643468wmb.6
        for <linux-mm@kvack.org>; Thu, 04 Apr 2019 14:58:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent:sender;
        bh=t2r4RUdx2KLqeGU2q+y5u90TLB8px4mQEQWHCFZECI4=;
        b=KMYAZr3Cu4oh38olWyWV6s+jqa4BBYp6qzTqn0VUSz5Hl68fcGfDZTxnxSbURF2yAV
         OArBsekdhCLGIbV8zCZbWY7kUH8JDc0ThNsRCAf/AKZ0CIzhvnWMYlTYeE9fxSWIJFUX
         hN+w70J8G7dlv/dTD/EK82RHughs32quYHh5EJt+YorGZfQox+U+LSLfPi2sw9YKynS5
         NGVbmb55gCvYQzg8zsv78E4uvo6u6U/KGkd7kFAoJEtMLZQZt+Z9xkktGnE2c477kIOf
         hhCpiYtmvAAp7E5C8iviy5X3rqjQyKnIIoI1R/U3GLaddOcg9XYB7l/Yf3lT5F1gw5fU
         lR9A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of viro@ftp.linux.org.uk designates 195.92.253.2 as permitted sender) smtp.mailfrom=viro@ftp.linux.org.uk
X-Gm-Message-State: APjAAAWFMVoM33ltazivEdvmQL8/aXVS+QuR3ADCwYtfmlbL+yR+cZSe
	zT6ntGVIm8mIcWL7/Af6pZgeZMmhToWoyTJarvZ6HWNAY7VHn7jybRlUShGRO2geVaT+H0JkrVM
	1Ug4N1gqnMam2tZTUzlg3n33W6VuNyDy7TVqd7Q4An6ukPVDmpqMvzysQ9QtW7nUACQ==
X-Received: by 2002:a1c:99d5:: with SMTP id b204mr5399399wme.95.1554415125086;
        Thu, 04 Apr 2019 14:58:45 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw6J9VqnNpNAV78KNGk2DKls0WsWH0hujzRsZ/Gl+I6/JRNG2tJCL6/yoqzsaRr+NEQHQ5B
X-Received: by 2002:a1c:99d5:: with SMTP id b204mr5399364wme.95.1554415124326;
        Thu, 04 Apr 2019 14:58:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554415124; cv=none;
        d=google.com; s=arc-20160816;
        b=g/3/gIu+7gXACZEzIoptrt71vV5w4uIVEjdLNVblWIqwx2AVb1vARl0i/w9hY0QIHl
         57bfZUmkm+wH3DNgX27rl2PJ21ZKC4JnfNnmLsR/WOpDcklKy1dGgRO1fxU5V3yh3aUG
         wtwY5XSHFDc1ge5N9biyub68B22IxCgywwLjuo9QbcZ5J7kbB0lTbyln5fhrc7YxctZ8
         qiNXCsdFWrJrKnuWogpCVLMAT7rwjGgkVttH+7E4QObZdfrmsXeUihllCjXNwEWI+RBk
         Rfw0GMJc3I0i3lAw3DqhsZM5qNkWWWfnHo0FzRqCDdTCXI2TOpQnd0MdvXxqVX4EnOnv
         yn6Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=sender:user-agent:in-reply-to:content-disposition:mime-version
         :references:message-id:subject:cc:to:from:date;
        bh=t2r4RUdx2KLqeGU2q+y5u90TLB8px4mQEQWHCFZECI4=;
        b=zg+jMCe9+R+PtvRpb6PvpecyVTJdSQAAvdaZcSSAmEN4BrSW8MiYwA5FTXu3KgATI2
         lvXwqI0cxWHyKhdtl1N5ZlktxyPE9RLGvgI+1qdz0uQZFebueHGzuT5z1iGm48t9HzTk
         GTIskt1xm/rb4lSJh5/xl+buToV+jAQZaBozjL+ylh4e7CI9mUu7nL6MRQ+tw4g8zQJ1
         mJjgaRa8fP2nz2m4taDfo15nCN04lh7T9oy0qWQTPYPJZhXCSE663inbZDYVoAvyH/uW
         agSqDsXBtz0iRae7Pm6ii+at4M8nL889uCbfEtiVqEkPDlD6yBuYkZy2yk8E0QahSsiQ
         qtqw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of viro@ftp.linux.org.uk designates 195.92.253.2 as permitted sender) smtp.mailfrom=viro@ftp.linux.org.uk
Received: from ZenIV.linux.org.uk (zeniv.linux.org.uk. [195.92.253.2])
        by mx.google.com with ESMTPS id o10si13130321wru.18.2019.04.04.14.58.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 04 Apr 2019 14:58:44 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of viro@ftp.linux.org.uk designates 195.92.253.2 as permitted sender) client-ip=195.92.253.2;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of viro@ftp.linux.org.uk designates 195.92.253.2 as permitted sender) smtp.mailfrom=viro@ftp.linux.org.uk
Received: from viro by ZenIV.linux.org.uk with local (Exim 4.92 #3 (Red Hat Linux))
	id 1hCAN8-0007xG-8f; Thu, 04 Apr 2019 21:58:10 +0000
Date: Thu, 4 Apr 2019 22:58:10 +0100
From: Al Viro <viro@zeniv.linux.org.uk>
To: "Tobin C. Harding" <me@tobin.cc>
Cc: "Tobin C. Harding" <tobin@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Roman Gushchin <guro@fb.com>,
	Alexander Viro <viro@ftp.linux.org.uk>,
	Christoph Hellwig <hch@infradead.org>,
	Pekka Enberg <penberg@cs.helsinki.fi>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Christopher Lameter <cl@linux.com>,
	Matthew Wilcox <willy@infradead.org>,
	Miklos Szeredi <mszeredi@redhat.com>,
	Andreas Dilger <adilger@dilger.ca>,
	Waiman Long <longman@redhat.com>, Tycho Andersen <tycho@tycho.ws>,
	Theodore Ts'o <tytso@mit.edu>, Andi Kleen <ak@linux.intel.com>,
	David Chinner <david@fromorbit.com>,
	Nick Piggin <npiggin@gmail.com>, Rik van Riel <riel@redhat.com>,
	Hugh Dickins <hughd@google.com>, linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
	Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [RFC PATCH v2 14/14] dcache: Implement object migration
Message-ID: <20190404215810.GG2217@ZenIV.linux.org.uk>
References: <20190403042127.18755-1-tobin@kernel.org>
 <20190403042127.18755-15-tobin@kernel.org>
 <20190403170811.GR2217@ZenIV.linux.org.uk>
 <20190403171920.GS2217@ZenIV.linux.org.uk>
 <20190403174855.GT2217@ZenIV.linux.org.uk>
 <20190404202914.GA16709@eros.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190404202914.GA16709@eros.localdomain>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Apr 05, 2019 at 07:29:14AM +1100, Tobin C. Harding wrote:
> > __d_alloc() is not holding ->d_lock, since the object is not visible to
> > anybody else yet; with your changes it *is* visible.
> 
> I don't quite understand this comment.  How is the object visible?  The
> constructor is only called when allocating a new page to the slab and
> this is done with interrupts disabled.

Not to constructor, to your try-to-evict code...

