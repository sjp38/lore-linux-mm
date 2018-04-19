Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5850F6B0005
	for <linux-mm@kvack.org>; Thu, 19 Apr 2018 17:26:19 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id 203so3412582pfz.19
        for <linux-mm@kvack.org>; Thu, 19 Apr 2018 14:26:19 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id d19si3440084pgn.379.2018.04.19.14.26.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Apr 2018 14:26:18 -0700 (PDT)
Subject: Re: [do_execve] attempted to set unsupported pgprot
References: <20180418135933.t3dyszi2phhsvaah@wfg-t540p.sh.intel.com>
 <20180418125916.a8be1fac1ac017f41a10f0fb@linux-foundation.org>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <e8f57e63-2657-6193-55e0-b097363ec97a@linux.intel.com>
Date: Thu, 19 Apr 2018 14:26:15 -0700
MIME-Version: 1.0
In-Reply-To: <20180418125916.a8be1fac1ac017f41a10f0fb@linux-foundation.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Fengguang Wu <fengguang.wu@intel.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Linus Torvalds <torvalds@linux-foundation.org>, Kees Cook <keescook@chromium.org>, Serge Hallyn <serge@hallyn.com>, James Morris <james.l.morris@oracle.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, lkp@01.org

On 04/18/2018 12:59 PM, Andrew Morton wrote:
> Dave, fb43d6cb91ef57 ("x86/mm: Do not auto-massage page protections")
> looks like a culprit?

This looks like a problem when a 32-bit kernel runs on hardware without
NX support.  I'm digging into it but haven't found a root cause yet.
