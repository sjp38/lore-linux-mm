Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id CE93C6B025E
	for <linux-mm@kvack.org>; Mon, 27 Jun 2016 07:38:00 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id a4so117884849lfa.1
        for <linux-mm@kvack.org>; Mon, 27 Jun 2016 04:38:00 -0700 (PDT)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id s188si13452460wme.29.2016.06.27.04.37.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Jun 2016 04:37:58 -0700 (PDT)
Received: by mail-wm0-f65.google.com with SMTP id 187so23800136wmz.1
        for <linux-mm@kvack.org>; Mon, 27 Jun 2016 04:37:58 -0700 (PDT)
Date: Mon, 27 Jun 2016 13:37:57 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] memory:bugxfix panic on cat or write /dev/kmem
Message-ID: <20160627113757.GH31799@dhcp22.suse.cz>
References: <1466703010-32242-1-git-send-email-chenjie6@huawei.com>
 <20160623124257.GB30082@dhcp22.suse.cz>
 <576DDC46.6050607@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <576DDC46.6050607@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Chenjie (K)" <chenjie6@huawei.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, David.Woodhouse@intel.com, zhihui.gao@huawei.com, panxuesong@huawei.com

On Sat 25-06-16 09:20:06, Chenjie (K) wrote:
> 
> 
> On 2016/6/23 20:42, Michal Hocko wrote:
> > On Fri 24-06-16 01:30:10, chenjie6@huawei.com wrote:
> > > From: chenjie <chenjie6@huawei.com>
> > > 
> > > cat /dev/kmem and echo > /dev/kmem will lead panic
> > 
> > Writing to /dev/kmem without being extremely careful is a disaster AFAIK
> > and even reading from the file can lead to unexpected results. Anyway
> > I am trying to understand what exactly you are trying to fix here. Why
> > writing to/reading from zero pfn should be any special wrt. any other
> > potentially dangerous addresses
> > 
> 
> cat /dev/mem not panic. cat /dev/kmem, just the user's operation for
> nothing.

I am sorry, but I do not follow. Could you be more specific please?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
