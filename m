Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 042726B03AB
	for <linux-mm@kvack.org>; Tue, 27 Jun 2017 12:42:57 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id 12so5955377wmn.1
        for <linux-mm@kvack.org>; Tue, 27 Jun 2017 09:42:56 -0700 (PDT)
Received: from mail-wm0-x234.google.com (mail-wm0-x234.google.com. [2a00:1450:400c:c09::234])
        by mx.google.com with ESMTPS id r11si14611287wrc.279.2017.06.27.09.42.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Jun 2017 09:42:55 -0700 (PDT)
Received: by mail-wm0-x234.google.com with SMTP id 62so30087299wmw.1
        for <linux-mm@kvack.org>; Tue, 27 Jun 2017 09:42:55 -0700 (PDT)
Date: Tue, 27 Jun 2017 19:42:53 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: Bad page state freeing hugepages
Message-ID: <20170627164253.guokov4uw26t4fq6@node.shutemov.name>
References: <20170615005612.5eeqdajx5qnhxxuf@sasha-lappy>
 <790f64f4-dd29-5a9c-b979-725a5b58805a@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <790f64f4-dd29-5a9c-b979-725a5b58805a@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "Levin, Alexander (Sasha Levin)" <alexander.levin@verizon.com>, "hughd@google.com" <hughd@google.com>, "mhocko@kernel.org" <mhocko@kernel.org>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Thu, Jun 22, 2017 at 07:22:09PM +0900, Tetsuo Handa wrote:
> FYI, I'm hitting this problem by doing just boot or shutdown sequence,
> and this problem is remaining as of next-20170622.

This should help:

http://lkml.kernel.org/r/20170627163734.6js4jkwkwlz6xwir@black.fi.intel.com

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
