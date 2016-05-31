Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f199.google.com (mail-lb0-f199.google.com [209.85.217.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3F4E76B025E
	for <linux-mm@kvack.org>; Tue, 31 May 2016 05:36:34 -0400 (EDT)
Received: by mail-lb0-f199.google.com with SMTP id q17so96136277lbn.3
        for <linux-mm@kvack.org>; Tue, 31 May 2016 02:36:34 -0700 (PDT)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id gg1si49460382wjd.214.2016.05.31.02.36.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 31 May 2016 02:36:33 -0700 (PDT)
Received: by mail-wm0-f66.google.com with SMTP id q62so30782013wmg.3
        for <linux-mm@kvack.org>; Tue, 31 May 2016 02:36:33 -0700 (PDT)
Date: Tue, 31 May 2016 11:36:31 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] reusing of mapping page supplies a way for file page
 allocation under low memory due to pagecache over size and is controlled by
 sysctl parameters. it is used only for rw page allocation rather than fault
 or readahead allocation. it is like relclaim but is lighter than reclaim. it
 only reuses clean and zero mapcount pages of mapping. for special
 filesystems using this feature like below:
Message-ID: <20160531093631.GH26128@dhcp22.suse.cz>
References: <1464685702-100211-1-git-send-email-zhouxianrong@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1464685702-100211-1-git-send-email-zhouxianrong@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhouxianrong@huawei.com
Cc: viro@zeniv.linux.org.uk, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, zhouxiyu@huawei.com, wanghaijun5@huawei.com, yuchao0@huawei.com

On Tue 31-05-16 17:08:22, zhouxianrong@huawei.com wrote:
> From: z00281421 <z00281421@notesmail.huawei.com>
> 
> const struct address_space_operations special_aops = {
>     ...
> 	.reuse_mapping_page = generic_reuse_mapping_page,
> }

Please try to write a proper changelog which explains what is the
change, why do we need it and who is it going to use.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
