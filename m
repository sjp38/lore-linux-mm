Received: from schroedinger.engr.sgi.com (schroedinger.engr.sgi.com [150.166.1.51])
	by netops-testserver-3.corp.sgi.com (Postfix) with ESMTP id CE8FD908AC
	for <linux-mm@kvack.org>; Fri, 29 Feb 2008 20:08:13 -0800 (PST)
Received: from clameter by schroedinger.engr.sgi.com with local (Exim 3.36 #1 (Debian))
	id 1JVJ1B-0004UH-00
	for <linux-mm@kvack.org>; Fri, 29 Feb 2008 20:08:13 -0800
Message-Id: <20080301040755.268426038@sgi.com>
Date: Fri, 29 Feb 2008 20:07:55 -0800
From: Christoph Lameter <clameter@sgi.com>
Subject: [rfc 00/10] [RFC] Page flags: Saving some, making handling easier etc.
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

A set of patches that attempts to improve page flag handling. First of all a
method is introduces to generate the page flag functions using macros. Then
the number of page flags used by sparsemem is reduced.

Then we add a way to export enum constant to the preprocessor which allows
us to get rid of __ZONE_COUNT and use the NR_PAGEFLAGS for the calculation
of actually available page flags for fields.

Lastly there is a land grab of page flags for various ongoing VM projects.
-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
