Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id C6D2F6B0032
	for <linux-mm@kvack.org>; Tue, 31 Mar 2015 05:46:05 -0400 (EDT)
Received: by wixo5 with SMTP id o5so4283695wix.1
        for <linux-mm@kvack.org>; Tue, 31 Mar 2015 02:46:05 -0700 (PDT)
Received: from mail-wg0-x230.google.com (mail-wg0-x230.google.com. [2a00:1450:400c:c00::230])
        by mx.google.com with ESMTPS id z1si22822453wiy.74.2015.03.31.02.46.02
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 31 Mar 2015 02:46:03 -0700 (PDT)
Received: by wgdm6 with SMTP id m6so12691638wgd.2
        for <linux-mm@kvack.org>; Tue, 31 Mar 2015 02:46:02 -0700 (PDT)
Message-ID: <551A6CD7.3040901@suse.cz>
Date: Tue, 31 Mar 2015 11:45:59 +0200
From: Jiri Slaby <jslaby@suse.cz>
MIME-Version: 1.0
Subject: Re: copy_huge_page: unable to handle kernel NULL pointer dereference
 at 0000000000000008
References: <CABYiri9MEbEnZikqTU3d=w6rxtsgumH2gJ++Qzi1yZKGn6it+Q@mail.gmail.com> <20150224001228.GA11456@amt.cnet> <CABYiri_U7oB==4-cxegjVQJ_dX62d0tX=D0cUAPTpV_xjCukEw@mail.gmail.com> <alpine.LSU.2.11.1503281705040.13543@eggly.anvils>
In-Reply-To: <alpine.LSU.2.11.1503281705040.13543@eggly.anvils>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Andrey Korolyov <andrey@xdel.ru>
Cc: Dave Hansen <dave.hansen@intel.com>, Greg KH <gregkh@linuxfoundation.org>, Luis Henriques <luis.henriques@canonical.com>, Marcelo Tosatti <mtosatti@redhat.com>, stable@vger.kernel.org, linux-mm@kvack.org, kvm@vger.kernel.org, wanpeng.li@linux.intel.com, jipan yang <jipan.yang@gmail.com>

On 03/29/2015, 01:25 AM, Hugh Dickins wrote:
> But you are very appositely mistaken: copy_huge_page() used to make
> the same mistake, and Dave Hansen fixed it back in v3.13, but the fix
> never went to the stable trees.
> 
> Your report was on an Ubuntu "3.11.0-15" kernel: I think Ubuntu have
> discontinued their 3.11-stable kernel series, but 3.10-longterm and
> 3.12-longterm would benefit from including this fix.  I haven't tried
> patching and  building and testing it there, but it looks reasonable.
> 
> Hugh
> 
> commit 30b0a105d9f7141e4cbf72ae5511832457d89788
> Author: Dave Hansen <dave.hansen@linux.intel.com>
> Date:   Thu Nov 21 14:31:58 2013 -0800
> 
>     mm: thp: give transparent hugepage code a separate copy_page

Applied to 3.12. Thanks.

-- 
js
suse labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
