Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6BD9E6B0010
	for <linux-mm@kvack.org>; Thu,  5 Jul 2018 11:05:54 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id h15-v6so9472564qkj.17
        for <linux-mm@kvack.org>; Thu, 05 Jul 2018 08:05:54 -0700 (PDT)
Received: from a9-46.smtp-out.amazonses.com (a9-46.smtp-out.amazonses.com. [54.240.9.46])
        by mx.google.com with ESMTPS id e9-v6si2723255qve.114.2018.07.05.08.05.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 05 Jul 2018 08:05:53 -0700 (PDT)
Date: Thu, 5 Jul 2018 15:05:53 +0000
From: Christopher Lameter <cl@linux.com>
Subject: Re: need help with slub.c duplicate filename '/kernel/slab/:t-0000048'
 problem
In-Reply-To: <CY4PR17MB1160BFB32620C1DD5646A9839F430@CY4PR17MB1160.namprd17.prod.outlook.com>
Message-ID: <010001646afa69e4-beca0ef4-73ee-42ab-a428-05d82761e6ff-000000@email.amazonses.com>
References: <CY4PR17MB1160BFB32620C1DD5646A9839F430@CY4PR17MB1160.namprd17.prod.outlook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: andy_purcell@keysight.com
Cc: linux-mm@kvack.org


See commit commit d50d82faa0c964e31f7a946ba8aba7c715ca7ab0
