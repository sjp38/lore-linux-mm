Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id B314C6B0002
	for <linux-mm@kvack.org>; Tue, 21 May 2013 06:13:11 -0400 (EDT)
Date: Tue, 21 May 2013 12:13:02 +0200
From: Karel Zak <kzak@redhat.com>
Subject: Re: [RFC PATCH 02/02] swapon: add "cluster-discard" support
Message-ID: <20130521101302.GA11774@x2.net.home>
References: <cover.1369092449.git.aquini@redhat.com>
 <398ace0dd3ca1283372b3aad3fceeee59f6897d7.1369084886.git.aquini@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <398ace0dd3ca1283372b3aad3fceeee59f6897d7.1369084886.git.aquini@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rafael Aquini <aquini@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, hughd@google.com, shli@kernel.org, jmoyer@redhat.com, riel@redhat.com, lwoodman@redhat.com, mgorman@suse.de

On Mon, May 20, 2013 at 09:04:25PM -0300, Rafael Aquini wrote:
> -	while ((c = getopt_long(argc, argv, "ahdefp:svVL:U:",
> +	while ((c = getopt_long(argc, argv, "ahcdefp:svVL:U:",
>  				long_opts, NULL)) != -1) {
>  		switch (c) {
>  		case 'a':		/* all */
> @@ -738,8 +753,11 @@ int main(int argc, char *argv[])
>  		case 'U':
>  			add_uuid(optarg);
>  			break;
> +		case 'c':
> +			discard += 2;
> +			break;
>  		case 'd':
> -			discard = 1;
> +			discard += 1;

 this is fragile, it would be better to use

        case 'c':
            discard |= SWAP_FLAG_DISCARD_CLUSTER;
            break;
        case 'd':
            discard |= SWAP_FLAG_DISCARD;
            break;

 and use directly the flags everywhere in the code than use magical
 numbers '1' and '2' etc.

    Karel

-- 
 Karel Zak  <kzak@redhat.com>
 http://karelzak.blogspot.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
