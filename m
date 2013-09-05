Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx118.postini.com [74.125.245.118])
	by kanga.kvack.org (Postfix) with SMTP id D2FE86B0031
	for <linux-mm@kvack.org>; Thu,  5 Sep 2013 10:41:55 -0400 (EDT)
Message-ID: <52289824.20000@intel.com>
Date: Thu, 05 Sep 2013 07:41:40 -0700
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/2 v2] mm: allow to set overcommit ratio more precisely
References: <1376925478-15506-1-git-send-email-jmarchan@redhat.com> <1376925478-15506-2-git-send-email-jmarchan@redhat.com> <52287E66.9010107@redhat.com>
In-Reply-To: <52287E66.9010107@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Marchand <jmarchan@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 09/05/2013 05:51 AM, Jerome Marchand wrote:
> This patch adds the new overcommit_ratio_ppm sysctl variable that
> allow to set overcommit ratio with a part per million precision.
> The old overcommit_ratio variable can still be used to set and read
> the ratio with a 1% precision. That way, overcommit_ratio interface
> isn't broken in any way that I can imagine.

Looks like a pretty sane solution.  Could you also make a Documentation/
update, please?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
