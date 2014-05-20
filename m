Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f173.google.com (mail-we0-f173.google.com [74.125.82.173])
	by kanga.kvack.org (Postfix) with ESMTP id 3B5FC6B0036
	for <linux-mm@kvack.org>; Tue, 20 May 2014 14:38:08 -0400 (EDT)
Received: by mail-we0-f173.google.com with SMTP id u57so958591wes.32
        for <linux-mm@kvack.org>; Tue, 20 May 2014 11:38:07 -0700 (PDT)
Received: from mail.zytor.com (terminus.zytor.com. [2001:1868:205::10])
        by mx.google.com with ESMTPS id eu11si9985152wjc.119.2014.05.20.11.38.06
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 May 2014 11:38:06 -0700 (PDT)
Message-ID: <537BA0FF.3000504@zytor.com>
Date: Tue, 20 May 2014 11:37:51 -0700
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/4] x86,mm: Improve _install_special_mapping and fix
 x86 vdso naming
References: <cover.1400538962.git.luto@amacapital.net> <276b39b6b645fb11e345457b503f17b83c2c6fd0.1400538962.git.luto@amacapital.net>
In-Reply-To: <276b39b6b645fb11e345457b503f17b83c2c6fd0.1400538962.git.luto@amacapital.net>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>, x86@kernel.org, Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <sasha.levin@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Dave Jones <davej@redhat.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Cyrill Gorcunov <gorcunov@gmail.com>, Pavel Emelyanov <xemul@parallels.com>, Cyrill Gorcunov <gorcunov@openvz.org>

On 05/19/2014 03:58 PM, Andy Lutomirski wrote:
> 
> As a side effect, the vvar area will show up in core dumps.  This
> could be considered weird and is fixable.  Thoughts?
> 

On this issue... I don't know if this is likely to break anything.  My
suggestion is that we accept it as-is but be prepared to deal with it if
it breaks something.
	
	-hpa


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
