Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8287C6B0005
	for <linux-mm@kvack.org>; Mon,  1 Aug 2016 10:08:27 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id 63so275693786pfx.0
        for <linux-mm@kvack.org>; Mon, 01 Aug 2016 07:08:27 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id ta8si29663529pab.231.2016.08.01.07.08.26
        for <linux-mm@kvack.org>;
        Mon, 01 Aug 2016 07:08:26 -0700 (PDT)
Subject: Re: [PATCH 0/3] new feature: monitoring page cache events
References: <cover.1469489884.git.gamvrosi@gmail.com>
 <579A72F5.10808@intel.com> <20160729034745.GA10234@leftwich>
 <579B774E.10309@intel.com> <20160730173115.GA23083@thinkpad>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <579F57A9.5020708@intel.com>
Date: Mon, 1 Aug 2016 07:07:37 -0700
MIME-Version: 1.0
In-Reply-To: <20160730173115.GA23083@thinkpad>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: George Amvrosiadis <gamvrosi@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On 07/30/2016 10:31 AM, George Amvrosiadis wrote:
> Dave, I can produce a patch that adds the extra two tracepoints and exports
> all four tracepoint symbols. This would be a short patch that would just
> extend existing tracing functionality. What do you think?

Adding those tracepoints is probably useful.  It's probably something we
need to have anyway as long as they don't cause too much code bloat or a
noticeable performance impact when they're off.

As for exporting symbols, that's not done until something is merged.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
