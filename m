Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 493506B0253
	for <linux-mm@kvack.org>; Thu, 18 Jan 2018 11:48:15 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id h5so155528pgv.21
        for <linux-mm@kvack.org>; Thu, 18 Jan 2018 08:48:15 -0800 (PST)
Received: from NAM02-CY1-obe.outbound.protection.outlook.com (mail-cys01nam02on0074.outbound.protection.outlook.com. [104.47.37.74])
        by mx.google.com with ESMTPS id p17si6495442pge.107.2018.01.18.08.48.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 18 Jan 2018 08:48:13 -0800 (PST)
From: Andrey Grodzovsky <andrey.grodzovsky@amd.com>
Subject: [RFC] Per file OOM badness
Date: Thu, 18 Jan 2018 11:47:48 -0500
Message-ID: <1516294072-17841-1-git-send-email-andrey.grodzovsky@amd.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, dri-devel@lists.freedesktop.org, amd-gfx@lists.freedesktop.org
Cc: Christian.Koenig@amd.com

Hi, this series is a revised version of an RFC sent by Christian KA?nig
a few years ago. The original RFC can be found at 
https://lists.freedesktop.org/archives/dri-devel/2015-September/089778.html

This is the same idea and I've just adressed his concern from the original RFC 
and switched to a callback into file_ops instead of a new member in struct file.

Thanks,
Andrey

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
