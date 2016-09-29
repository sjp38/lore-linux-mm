Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id B55AA280251
	for <linux-mm@kvack.org>; Thu, 29 Sep 2016 02:19:31 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id b130so62343952wmc.2
        for <linux-mm@kvack.org>; Wed, 28 Sep 2016 23:19:31 -0700 (PDT)
Received: from mail-wm0-x22f.google.com (mail-wm0-x22f.google.com. [2a00:1450:400c:c09::22f])
        by mx.google.com with ESMTPS id bc3si13069315wjb.53.2016.09.28.23.19.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Sep 2016 23:19:30 -0700 (PDT)
Received: by mail-wm0-x22f.google.com with SMTP id b4so5353246wmb.0
        for <linux-mm@kvack.org>; Wed, 28 Sep 2016 23:19:30 -0700 (PDT)
Date: Thu, 29 Sep 2016 08:19:27 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH v2 3/3] selinux: require EXECMEM for forced ptrace poke
Message-ID: <20160929061927.GA21794@gmail.com>
References: <1475103281-7989-1-git-send-email-jann@thejh.net>
 <1475103281-7989-4-git-send-email-jann@thejh.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1475103281-7989-4-git-send-email-jann@thejh.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jann Horn <jann@thejh.net>
Cc: security@kernel.org, Alexander Viro <viro@zeniv.linux.org.uk>, Paul Moore <paul@paul-moore.com>, Stephen Smalley <sds@tycho.nsa.gov>, Eric Paris <eparis@parisplace.org>, James Morris <james.l.morris@oracle.com>, "Serge E. Hallyn" <serge@hallyn.com>, Nick Kralevich <nnk@google.com>, Janis Danisevskis <jdanis@google.com>, linux-security-module@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org


* Jann Horn <jann@thejh.net> wrote:

> +{
> +	/* Permitting a write to readonly memory is fine - making the readonly
> +	 * memory executable afterwards would require EXECMOD permission because
> +	 * anon_vma would be non-NULL.
> +	 */

Minor stylistic nit: please fix this comment to be visually symmetric. (There's 
another one introduced by one of your other patches.)

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
