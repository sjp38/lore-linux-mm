Date: Thu, 7 Sep 2000 10:59:48 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: rhosts does not work???
Message-ID: <20000907105948.A1329@redhat.com>
Reply-To: Stephen Tweedie <sct@redhat.com>,
	  Sahil <aakgefce@rurkiu.ernet.in>
References: <Pine.OSF.3.96.1000907132440.24544A-100000@isc.rurkiu.ernet.in>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.OSF.3.96.1000907132440.24544A-100000@isc.rurkiu.ernet.in>; from aakgefce@rurkiu.ernet.in on Thu, Sep 07, 2000 at 01:27:51PM +0500
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Sahil <aakgefce@rurkiu.ernet.in>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Thu, Sep 07, 2000 at 01:27:51PM +0500, Sahil wrote:

> I have been trying to put .rhosts with '+ +' in it but it does not work.
> Can any body tell me the substitute??

FIrst, this is the wrong mailing list for this, so please take the
rest of this topic off-list!

Second, .rhosts should work fine, but (just as for any unix) you need
to be very careful with the permissions on both the .rhosts file and the
directory containing it.  Both should have no group write, in
particular, or else rsh will complain.
 
> How to define the principles for .klogin (kerberos)??

Do you already have a master KDC?  If so, you can just use kadmin to
generate new principals.  If not, read the info pages on setting up
the KDC.

gkadmin is usually in /usr/kerberos/sbin/kadmin.  You need to have an
admin principle set up to begin with --- you will already have done
that if you have Kerberos running at all.  New principals are added
with the "add_principal" command, and their passwords set with
"change_password".  Once you have a principal set for your user ID,
"kinit" to login (or "kinit -f", which I normally use, to obtain
tickets which can be forwarded to other hosts).  Then all you need for
kerberised login is a ~/.k5login (~/.klogin is only for Kerberos 4,
and on Linux I assume you have krb5).  Just list the authorised
principals in there.

Cheers,
 Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
