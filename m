Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id F04E66B0005
	for <linux-mm@kvack.org>; Sun, 24 Feb 2013 15:40:37 -0500 (EST)
Message-ID: <512A7AC4.5000006@ubuntu.com>
Date: Sun, 24 Feb 2013 15:40:36 -0500
From: Phillip Susi <psusi@ubuntu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/2] mm: fadvise: fix POSIX_FADV_DONTNEED
References: <1361660281-22165-1-git-send-email-psusi@ubuntu.com> <1361660281-22165-2-git-send-email-psusi@ubuntu.com> <5129710F.6060804@linux.vnet.ibm.com> <51298B0C.2020400@ubuntu.com> <512A5AC4.30808@linux.vnet.ibm.com>
In-Reply-To: <512A5AC4.30808@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

On 02/24/2013 01:24 PM, Dave Hansen wrote:
> These are folks that want to use the page cache, but also want to
> be in control of when it gets written out (sync_file_range() is
> used) and when it goes away.  Sure, they can use O_DIRECT and do
> all of the buffering internally, but that means changing the
> application.
> 
> I actually really like the concept behind your patch.  It looks
> like very useful functionality.  I'm just saying that I know it
> will break _existing_ users.

I'm not seeing how it will break anything.  Which aspect of the
current behavior is the app relying on?  If it is the immediate
removal of clean pages from the cache, then it should not care about
the new behavior since the pages will still be removed very soon when
under high cache pressure.


-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)
Comment: Using GnuPG with undefined - http://www.enigmail.net/

iQEcBAEBAgAGBQJRKnrEAAoJEJrBOlT6nu75swEIALnyhEwJ38Q6UUIfwFZcOgGm
J1HF6e0jvoDmcjqwC+bInmnaYVtsbeimGZSbugxOTHw+pwNiV7twPf+b6KOrPt6F
GzVpHtVP2dCrrnhsWwCjIcJYBDOlRx2lpVEiOWPE6WpH2O8/GmlTadCx+bWjndbg
0lIdbmhaBOIlI2jWaSen0xWVaJM9Peh5cA7hS8lZOYYSckiKbZ1fsLV378zc8ltp
yC39SzZ0JuAfJfYqGI56fWfOdwHLbZiyYB8VmKIRsGtHU89ITvWH8vF7h5pf9VaV
cwdrNa4d2aLrpy95O2gMW0V+G+0lFDrpUszZets0u5r6ihi9jjt/akyImIO4U58=
=qMk5
-----END PGP SIGNATURE-----

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
