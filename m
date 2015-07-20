Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f46.google.com (mail-qg0-f46.google.com [209.85.192.46])
	by kanga.kvack.org (Postfix) with ESMTP id B8A349003C7
	for <linux-mm@kvack.org>; Mon, 20 Jul 2015 11:32:12 -0400 (EDT)
Received: by qgeu79 with SMTP id u79so18429653qge.1
        for <linux-mm@kvack.org>; Mon, 20 Jul 2015 08:32:12 -0700 (PDT)
Received: from resqmta-ch2-08v.sys.comcast.net (resqmta-ch2-08v.sys.comcast.net. [2001:558:fe21:29:69:252:207:40])
        by mx.google.com with ESMTPS id 63si24531828qhw.101.2015.07.20.08.32.11
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Mon, 20 Jul 2015 08:32:12 -0700 (PDT)
Date: Mon, 20 Jul 2015 10:32:10 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 1/3] percpu: clean up of schunk->map[] assignment in
 pcpu_setup_first_chunk
In-Reply-To: <1437404130-5188-1-git-send-email-bhe@redhat.com>
Message-ID: <alpine.DEB.2.11.1507201031110.14535@east.gentwo.org>
References: <1437404130-5188-1-git-send-email-bhe@redhat.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Baoquan He <bhe@redhat.com>
Cc: tj@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 20 Jul 2015, Baoquan He wrote:

> The original assignment is a little redundent.

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
