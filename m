Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id 551FE6B0075
	for <linux-mm@kvack.org>; Fri,  6 Jul 2012 01:42:40 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so16922844pbb.14
        for <linux-mm@kvack.org>; Thu, 05 Jul 2012 22:42:39 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1341545097-9933-1-git-send-email-shangw@linux.vnet.ibm.com>
References: <1341545097-9933-1-git-send-email-shangw@linux.vnet.ibm.com>
Date: Fri, 6 Jul 2012 13:42:39 +0800
Message-ID: <CAM_iQpUQN0EEFf5G3RMiR5_51-Pfm2n1kqtQhRuTjQz-wvsmjw@mail.gmail.com>
Subject: Re: [PATCH] mm/buddy: more comments for skip_free_areas_node()
From: Cong Wang <xiyou.wangcong@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gavin Shan <shangw@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org

On Fri, Jul 6, 2012 at 11:24 AM, Gavin Shan <shangw@linux.vnet.ibm.com> wrote:
> The initial idea comes from Cong Wang. We're running out of memory
> while calling function skip_free_areas_node(). So it would be unsafe
> to allocate more memory from either stack or heap. The patche adds
> more comments to address that.

I think these comments should add to show_free_areas(),
not skip_free_areas_node().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
