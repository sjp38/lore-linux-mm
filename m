Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 553A86B0003
	for <linux-mm@kvack.org>; Thu, 15 Feb 2018 11:40:16 -0500 (EST)
Received: by mail-it0-f72.google.com with SMTP id w184so708461ita.0
        for <linux-mm@kvack.org>; Thu, 15 Feb 2018 08:40:16 -0800 (PST)
Received: from resqmta-ch2-12v.sys.comcast.net (resqmta-ch2-12v.sys.comcast.net. [69.252.207.44])
        by mx.google.com with ESMTPS id k3si1924880itg.33.2018.02.15.08.40.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Feb 2018 08:40:15 -0800 (PST)
Date: Thu, 15 Feb 2018 10:39:13 -0600 (CST)
From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH 1/3] percpu: match chunk allocator declarations with
 definitions
In-Reply-To: <3865d86559d8499f9bbb12f578bf9e6aa8f8882e.1518668149.git.dennisszhou@gmail.com>
Message-ID: <alpine.DEB.2.20.1802151038510.2970@nuc-kabylake>
References: <cover.1518668149.git.dennisszhou@gmail.com> <3865d86559d8499f9bbb12f578bf9e6aa8f8882e.1518668149.git.dennisszhou@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dennis Zhou <dennisszhou@gmail.com>
Cc: Tejun Heo <tj@kernel.org>, Daniel Borkmann <daniel@iogearbox.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 15 Feb 2018, Dennis Zhou wrote:

> At some point the function declaration parameters got out of sync with
> the function definitions in percpu-vm.c and percpu-km.c. This patch
> makes them match again.

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
